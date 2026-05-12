import { Request, Response, NextFunction } from 'express';

import admin from '../../config/firebase/firebase';

export async function verifyFirebaseToken(
  req: Request,
  res: Response,
  next: NextFunction
) {
  try {
    const authHeader =
      req.headers.authorization;

    if (!authHeader) {
      return res.status(401).json({
        error: 'Token required',
      });
    }

    const token = authHeader.replace(
      'Bearer ',
      ''
    );

    const decoded =
      await admin.auth().verifyIdToken(token);

    (req as any).user = decoded;

    next();
  } catch (error) {
    return res.status(401).json({
      error: 'Invalid token',
    });
  }
}