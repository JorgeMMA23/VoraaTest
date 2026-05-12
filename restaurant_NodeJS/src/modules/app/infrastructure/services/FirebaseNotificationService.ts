import admin from '../../../../config/firebase/firebase';

export class FirebaseNotificationService {
    async sendToDevice(params: {
        token: string;
        title: string;
        body: string;
        data?: Record<string, string>;
    }) {
        const message = {
            token: params.token,

            notification: {
                title: params.title,
                body: params.body,
            },

            data: params.data || {},

            android: {
                priority: 'high' as const,
            },

            apns: {
                payload: {
                    aps: {
                        sound: 'default',
                    },
                },
            },
        };

        try {
            await admin.messaging().send(message);
        } catch (error: any) {
            if (
                error.code ===
                'messaging/registration-token-not-registered'
            ) {
                // eliminar token inválido
            }
        }
    }
}