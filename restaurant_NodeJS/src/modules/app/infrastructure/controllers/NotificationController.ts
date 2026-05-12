import { Request, Response } from 'express';
import { FirebaseNotificationService } from '../services/FirebaseNotificationService';

const notificationService =
  new FirebaseNotificationService();

export class NotificationController {
  async sendToUser(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      const result =
        await notificationService.sendToDevice({
          token: req.body.token,
          title: req.body.title,
          body: req.body.body,
          data: req.body.data,
        });

      return res.json({
        success: true,
        messageId: result,
      });
    } catch (error) {
      console.error(error);

      return res.status(500).json({
        success: false,
        error: 'Notification failed',
      });
    }
  }
}