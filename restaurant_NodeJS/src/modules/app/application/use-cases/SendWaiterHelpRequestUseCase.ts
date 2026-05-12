import { TableRepository } from '../../domain/repositories/TableRepository';
import { WaiterRepository } from '../../domain/repositories/WaiterRepository';
import { FirebaseNotificationService } from '../../infrastructure/services/FirebaseNotificationService';
import { AppError } from '../../../../shared/errors/AppErrors';

export class SendWaiterHelpRequestUseCase {
  constructor(
    private tableRepository: TableRepository,
    private waiterRepository: WaiterRepository,
    private notificationService: FirebaseNotificationService,
  ) {}

  async execute(tableId: string): Promise<void> {
    // Obtener mesa por ID
    const table = await this.tableRepository.findById(tableId);
    if (!table) {
      throw new AppError('Mesa no encontrada');
    }

    // Validar que la mesa tiene un mesero asignado
    if (!table.assignedWaiterId) {
      throw new AppError('La mesa no tiene mesero asignado');
    }

    // Obtener datos del mesero
    const waiter = await this.waiterRepository.findById(table.assignedWaiterId);
    if (!waiter) {
      throw new AppError('Mesero no encontrado');
    }

    // Validar que el mesero tiene token de dispositivo
    if (!waiter.tokenDevice) {
      throw new AppError('El mesero no tiene token de notificación registrado');
    }

    // Enviar notificación push
    await this.notificationService.sendToDevice({
      token: waiter.tokenDevice,
      title: 'Solicitud de ayuda',
      body: `Mesa #${table.tableNumber} requiere tu ayuda`,
      data: {
        tableId: table.id,
        tableNumber: table.tableNumber,
        type: 'help_request',
      },
    });
  }
}
