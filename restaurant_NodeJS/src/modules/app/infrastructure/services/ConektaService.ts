import axios from 'axios';

export class ConektaService {
  private api = axios.create({
    baseURL: process.env.CONEKTA_BASE_URL,
    headers: {
      Accept: 'application/vnd.conekta-v2.1.0+json',
      'Content-Type': 'application/json',
      Authorization: `Bearer ${process.env.CONEKTA_API_KEY}`
    }
  });

  async createCustomer(data: {
    name: string;
    email: string;
    phone: string;
  }) {
    const response = await this.api.post('/customers', {
      name: data.name,
      email: data.email,
      phone: data.phone
    });

    return response.data;
  }

  async createCard(customerId: string, token: string) {
    const response = await this.api.post(
      `/customers/${customerId}/payment_sources`,
      {
        token_id: token,
        type: 'card'
      }
    );

    return response.data;
  }

  async createOrder(data: {
    customerId: string;
    amount: number;
    tokenId: string;
    description: string;
  }) {
    const response = await this.api.post('/orders', {
      currency: 'MXN',
      customer_info: {
        customer_id: data.customerId
      },
      line_items: [
        {
          name: data.description,
          unit_price: Math.round(data.amount * 100),
          quantity: 1
        }
      ],
      charges: [
        {
          payment_method: {
            type: 'card',
            token_id: data.tokenId
          }
        }
      ]
    });

    return response.data;
  }
}