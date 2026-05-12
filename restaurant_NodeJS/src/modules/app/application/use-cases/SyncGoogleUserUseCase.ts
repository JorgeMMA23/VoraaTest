import { User } from '../../domain/entities/User';

import { UserRepository } from '../../domain/repositories/UserRepository';

export class SyncGoogleUserUseCase {
  constructor(
    private repository: UserRepository
  ) {}

  async execute(input: {
    id: string;
    name: string;
    email: string;
    photoUrl?: string;
    token: string;
  }): Promise<User> {
    const existingUser =
      await this.repository.findByEmail(
        input.email
      );

    if (existingUser) {
      return existingUser;
    }

    const user: User = {
      id: input.id,
      name: input.name,
      email: input.email,
      photoUrl: input.photoUrl,
      role: 'customer',
      active: true,
      createdAt: new Date(),
      token: input.token
    };

    return this.repository.create(user);
  }
}