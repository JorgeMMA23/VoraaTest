import { Request, Response } from 'express';

import { FirebaseUserRepository } from '../repositories/FirebaseUserRepository';

import { SyncGoogleUserUseCase } from '../../application/use-cases/SyncGoogleUserUseCase';

const repository =
  new FirebaseUserRepository();

const syncUserUseCase =
  new SyncGoogleUserUseCase(repository);

export class AuthController {
  async me(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      const firebaseUser = req.body.user;

      console.log(firebaseUser)

      const user =
        await syncUserUseCase.execute({
          id: firebaseUser.uid,
          name:
            firebaseUser.name ||
            'Usuario',
          email: firebaseUser.email,
          photoUrl: firebaseUser.picture,
          token: req.body.token
        });

      return res.json(user);
    } catch (error) {
      console.error(error);

      return res.status(500).json({
        error: 'Internal server error',
      });
    }
  }

  async updateToken(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      const { token } = req.body;
      const firebaseUser = (req as any).user;
      await repository.update(firebaseUser.uid, token);
      return res.json({ success: true });
    } catch (error) {
      console.error(error);

      return res.status(500).json({
        error: 'Internal server error',
      });
    } }
}