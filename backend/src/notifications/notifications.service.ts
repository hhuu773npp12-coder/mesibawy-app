import { HttpException, HttpStatus, Injectable, NotFoundException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { NotificationEntity } from './notification.entity';
import { User } from '../users/user.entity';

@Injectable()
export class NotificationsService {
  private appId: string;
  private apiKey: string;

  constructor(
    private readonly config: ConfigService,
    @InjectRepository(NotificationEntity) private readonly repo: Repository<NotificationEntity>,
    @InjectRepository(User) private readonly usersRepo: Repository<User>,
  ) {
    this.appId = this.config.get<string>('ONESIGNAL_APP_ID', '');
    this.apiKey = this.config.get<string>('ONESIGNAL_API_KEY', '');
  }

  private ensureConfigured() {
    if (!this.appId || !this.apiKey) {
      throw new HttpException('OneSignal is not configured', HttpStatus.PRECONDITION_REQUIRED);
    }
  }

  async sendToAll(title: string, message: string, data?: Record<string, any>) {
    this.ensureConfigured();
    const payload = {
      app_id: this.appId,
      included_segments: ['Total Subscriptions'],
      headings: { en: title, ar: title },
      contents: { en: message, ar: message },
      data,
    };
    const res = await fetch('https://api.onesignal.com/api/v1/notifications', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Basic ${this.apiKey}`,
      },
      body: JSON.stringify(payload),
    });
    if (!res.ok) throw new HttpException('OneSignal error', res.status);
    return res.json();
  }

  async sendToExternalUserIds(userIds: string[], title: string, message: string, data?: Record<string, any>) {
    this.ensureConfigured();
    const payload = {
      app_id: this.appId,
      include_external_user_ids: userIds,
      headings: { en: title, ar: title },
      contents: { en: message, ar: message },
      data,
    };
    const res = await fetch('https://api.onesignal.com/api/v1/notifications', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Basic ${this.apiKey}`,
      },
      body: JSON.stringify(payload),
    });
    if (!res.ok) throw new HttpException('OneSignal error', res.status);
    return res.json();
  }

  async sendToTags(tags: Array<{ key: string; relation: '=' | '!=' | 'exists' | 'not_exists' | '>' | '<'; value?: string }>, title: string, message: string, data?: Record<string, any>) {
    this.ensureConfigured();
    const payload = {
      app_id: this.appId,
      filters: tags.map((t, i) =>
        i === 0
          ? { field: 'tag', key: t.key, relation: t.relation, value: t.value }
          : [{ operator: 'AND' }, { field: 'tag', key: t.key, relation: t.relation, value: t.value }],
      ).flat(),
      headings: { en: title, ar: title },
      contents: { en: message, ar: message },
      data,
    };
    const res = await fetch('https://api.onesignal.com/api/v1/notifications', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Basic ${this.apiKey}`,
      },
      body: JSON.stringify(payload),
    });
    if (!res.ok) throw new HttpException('OneSignal error', res.status);
    return res.json();
  }

  // DB-backed notifications for in-app listing
  async listForUser(userId: string) {
    const user = await this.usersRepo.findOne({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');
    return this.repo.find({ where: { user }, order: { createdAt: 'DESC' } });
  }

  async markAllRead(userId: string) {
    const user = await this.usersRepo.findOne({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');
    await this.repo.createQueryBuilder()
      .update(NotificationEntity)
      .set({ read: true })
      .where('userId = :uid', { uid: userId })
      .andWhere('read = false')
      .execute();
    const unread = await this.repo.count({ where: { user, read: false } });
    return { ok: true, unread };
  }
}
