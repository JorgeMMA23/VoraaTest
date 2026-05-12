import { Request, Response } from 'express';
import { FirebaseOrderRepository } from '../repositories/FirebaseOrderRepository';
import { FirebaseMenuRepository } from '../repositories/FirebaseMenuRepository';
import { FirebasePromotionRepository } from '../repositories/FirebasePromotionRepository';
import { CreateOrderUseCase } from '../../application/use-cases/CreateOrderUseCase';
import { UpdateOrderStatusUseCase } from '../../application/use-cases/UpdateOrderStatusUseCase';
import { Order } from '../../domain/entities/Order';
import { Promotion } from '../../domain/entities/Promotion';
import { FirebaseTableRepository } from '../repositories/FirebaseTableRepository';
import { FirebaseWaiterRepository } from '../repositories/FirebaseWaiterRepository';
import { FirebaseNotificationService } from '../services/FirebaseNotificationService';
import { SendWaiterHelpRequestUseCase } from '../../application/use-cases/SendWaiterHelpRequestUseCase';
import { GetTotalTipsByPaidOrdersUseCase } from '../../application/use-cases/GetTotalTipsByPaidOrdersUseCase';

type TipOption = '0%' | '10%' | '15%' | '20%';

const repository =
  new FirebaseOrderRepository();

const menuRepository =
  new FirebaseMenuRepository();

const promotionRepository =
  new FirebasePromotionRepository();

const createOrderUseCase =
  new CreateOrderUseCase(repository);

const updateStatusUseCase =
  new UpdateOrderStatusUseCase(repository);

const getTotalTipsByPaidOrdersUseCase =
  new GetTotalTipsByPaidOrdersUseCase(repository);

  const tableRepository =
    new FirebaseTableRepository();
  
  const waiterRepository =
    new FirebaseWaiterRepository();
  
  const notificationService =
    new FirebaseNotificationService();

  const sendHelpRequestUseCase =
  new SendWaiterHelpRequestUseCase(
    tableRepository,
    waiterRepository,
    notificationService
  );

type DateValue = Date | {
  toDate: () => Date;
};

export class OrderController {
  private toDate(value: DateValue): Date {
    if (value instanceof Date) {
      return value;
    }

    return value.toDate();
  }

  private isPromotionApplicable(
    promotion: Promotion
  ): boolean {
    const now = new Date();
    const startDate = this.toDate(
      promotion.startDate as DateValue
    );
    const endDate = this.toDate(
      promotion.endDate as DateValue
    );

    return promotion.active &&
      now >= startDate &&
      now <= endDate;
  }

  private calculateSubtotal(order: Order): number {
    return this.roundMoney(order.items.reduce(
      (acc, item) =>
        acc + ( item.price || item.unitPrice) * item.quantity,
      0
    ));
  }

  private roundMoney(value: number): number {
    return Math.round(value * 100) / 100;
  }

  private calculateTipOptions(
    subtotal: number,
    totalWithoutTip: number
  ): Record<string, {
    percentage: number;
    tip: number;
    total: number;
  }> {
    return {
      '0': {
        percentage: 0,
        tip: 0,
        total: totalWithoutTip + subtotal, 
      },
      '10': {
        percentage: 10,
        tip: this.roundMoney(subtotal * 0.1),
        total: this.roundMoney(
          totalWithoutTip + subtotal * 0.1
        ),
      },
      '15': {
        percentage: 15,
        tip: this.roundMoney(subtotal * 0.15),
        total: this.roundMoney(
          totalWithoutTip + subtotal * 0.15
        ),
      },
      '20': {
        percentage: 20,
        tip: this.roundMoney(subtotal * 0.2),
        total: this.roundMoney(
          totalWithoutTip + subtotal * 0.2
        ),
      },
    };
  }

  private async getOrderWithProducts(
    order: Order
  ): Promise<Order & {
    items: Array<Order['items'][number] & {
      product: Awaited<ReturnType<
        FirebaseMenuRepository['findById']
      >>;
    }>;
  }> {
    const items = await Promise.all(
      order.items.map(async (item) => ({
        ...item,
        product: await menuRepository.findById(
          item.productId
        ),
      }))
    );

    return {
      ...order,
      items,
    };
  }

  async create(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      const order =
        await createOrderUseCase.execute(
          req.body
        );

      return res.status(201).json(order);
    } catch (error) {
      console.error(error);

      return res.status(500).json({
        error: 'Failed to create order',
      });
    }
  }

  async getAll(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      const orders =
        await repository.findAll();

      return res.json(orders);
    } catch (error) {
      return res.status(500).json({
        error: 'Internal server error',
      });
    }
  }

  async getById(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      const order =
        await repository.findById(
          req.params.id.toString()
        );

      if (!order) {
        return res.status(404).json({
          error: 'Order not found',
        });
      }

      const orderWithProducts =
        await this.getOrderWithProducts(order);

      return res.json(orderWithProducts);
    } catch (error) {
      return res.status(500).json({
        error: 'Internal server error',
      });
    }
  }

  async getByIdWithCoupon(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      const selectedTip: TipOption = req.body.tip as TipOption || '0%';
      console.log(selectedTip)
      const order =
        await repository.findById(
          req.params.id.toString()
        );
      //console.log(order)
      if (!order) {
        return res.status(404).json({
          error: 'Order not found',
        });
      }

      let promotion: Promotion | null = null;

      if (req.params.couponId) {
        promotion =
          await promotionRepository.findById(
            req.params.couponId.toString()
          );
      }

      console.log(promotion)

      // if (!promotion) {
      //   return res.status(404).json({
      //     error: 'Promotion not found',
      //   });
      // }

      const orderWithProducts =
        await this.getOrderWithProducts(order);

      const subtotal =
        this.calculateSubtotal(order);

      console.log(subtotal)

      let promotionApplies = true;
      // if (promotion) {
      //   promotionApplies =
      //     this.isPromotionApplicable(promotion);
      // }

      const discount =
        promotionApplies
          ? this.roundMoney(
            subtotal *
            ( (promotion ?  promotion.discountPercentage : 0) / 100)
          )
          : 0;

      console.log(discount)

      const tips: Record<TipOption, number> = {
        '0%': 0,
        '10%': this.roundMoney(
          subtotal * 0.10
        ),
        '15%': this.roundMoney(
          subtotal * 0.15
        ),
        '20%': this.roundMoney(
          subtotal * 0.2

        )
      }

      const total = this.roundMoney(
        subtotal - discount + (selectedTip ? tips[selectedTip] : 0)
      );

      console.log(total)

      const totalWithoutTip =
        this.roundMoney(subtotal - discount);

        console.log({
        ...orderWithProducts,
        promotion: {
          ...promotion,
          applied: promotionApplies,
        },
        calculations: {
          subtotal,
          discount,
          selectedTip,
          total,
          totalWithoutTip,
          tipOptions: this.calculateTipOptions(
            subtotal,
            totalWithoutTip
          ),
        },
      })

      return res.json({
        ...orderWithProducts,
        promotion: {
          ...promotion,
          applied: promotionApplies,
        },
        calculations: {
          subtotal,
          discount,
          selectedTip,
          total,
          totalWithoutTip,
          tipOptions: this.calculateTipOptions(
            subtotal,
            totalWithoutTip
          ),
        },
      });
    } catch (error) {
      return res.status(500).json({
        error: 'Internal server error',
      });
    }
  }

  async updateStatus(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      await updateStatusUseCase.execute(
        req.params.id.toString(),
        req.body
      );

      return res.json({
        success: true,
      });
    } catch (error) {
      return res.status(500).json({
        error: 'Failed updating order',
      });
    }
  }

  async delete(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      await repository.delete(
        req.params.id.toString()
      );

      return res.status(204).send();
    } catch (error) {
      return res.status(500).json({
        error: 'Internal server error',
      });
    }
  }

  async getTotalTipsPaid(
    _req: Request,
    res: Response
  ): Promise<Response> {
    try {
      const total =
        await getTotalTipsByPaidOrdersUseCase.execute();

      return res.json({ totalTips: total });
    } catch (error) {
      return res.status(500).json({
        error: 'Failed to get total tips',
      });
    }
  }

  async sendHelpRequest(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {

      await sendHelpRequestUseCase.execute(
        req.params.id.toString()
      );

      return res.json({
        success: true,
      });
    } catch (error) {
      console.error(error);

      return res.status(500).json({
        error: 'Failed to send help request',
      });
    } 
  }
}
