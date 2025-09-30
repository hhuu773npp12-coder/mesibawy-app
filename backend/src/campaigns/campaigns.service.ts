import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Campaign } from './campaign.entity';
import { CampaignBooking } from './campaign-booking.entity';
import { User } from '../users/user.entity';
import { NotificationsService } from '../notifications/notifications.service';

@Injectable()
export class CampaignsService {
  constructor(
    @InjectRepository(Campaign)
    private readonly repo: Repository<Campaign>,
    @InjectRepository(CampaignBooking)
    private readonly bookingRepo: Repository<CampaignBooking>,
    @InjectRepository(User)
    private readonly usersRepo: Repository<User>,
    private readonly notifications?: NotificationsService,
  ) {}

  create(data: { title: string; originArea: string; seatsTotal: number; pricePerSeat: number }) {
    const c = this.repo.create({
      title: data.title,
      originArea: data.originArea,
      seatsTotal: Math.max(1, Math.floor(data.seatsTotal)),
      pricePerSeat: Math.max(0, Math.floor(data.pricePerSeat)),
      seatsBooked: 0,
      active: true,
    });
    return this.repo.save(c);
  }

  list() {
    return this.repo.find({ order: { createdAt: 'DESC' } });
  }

  async sharePlaceholder(id: string) {
    const c = await this.repo.findOne({ where: { id } });
    if (!c) throw new NotFoundException('Campaign not found');
    // لاحقاً: مشاركة الحملة مع أصحاب مركبات نقل الركاب حسب القرب/الرصيد/الحالة
    // إرسال إشعار OneSignal (إن كان مفعلاً) — مثال: للجميع أو لوسم محدد لاحقاً
    try {
      const data = { kind: 'campaign_share', campaignId: c.id } as const;
      // استهداف أصحاب دور كيا ركاب أولاً عبر الوسوم
      const tags = [{ key: 'role', relation: '=', value: 'kia_passenger' } as const];
      const sent = await this.notifications?.sendToTags(tags as any, 'حملة زيارة جديدة', `العنوان: ${c.title} — الانطلاق: ${c.originArea}`, data as any);
      if (!sent) {
        // احتياط: بث عام إن لم تتوفر الخدمة أو التهيئة
        await this.notifications?.sendToAll('حملة زيارة جديدة', `العنوان: ${c.title} — الانطلاق: ${c.originArea}`, data as any);
      }
    } catch (_) {
      // تجاهل فشل الإشعار أثناء التطوير
    }
    return { ok: true, message: 'تم تجهيز المشاركة وإرسال إشعار (عند التهيئة)', campaignId: id };
  }

  async book(campaignId: string, userId: string, count: number = 1) {
    const camp = await this.repo.findOne({ where: { id: campaignId } });
    if (!camp) throw new NotFoundException('Campaign not found');
    if (!camp.active) throw new BadRequestException('Campaign not active');

    const user = await this.usersRepo.findOne({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');

    // seats check
    const remaining = camp.seatsTotal - (camp.seatsBooked || 0);
    const toBook = Math.max(1, Math.floor(count));
    if (remaining <= 0 || remaining < toBook) throw new BadRequestException('No seats available');

    // optional: prevent duplicate booking for same user and campaign
    const existing = await this.bookingRepo.findOne({ where: { campaign: { id: campaignId }, user: { id: userId }, status: 'BOOKED' as any } });
    if (existing) throw new BadRequestException('Already booked');

    // create bookings and update seatsBooked
    const created: string[] = [];
    for (let i = 0; i < toBook; i++) {
      const booking = this.bookingRepo.create({ campaign: camp, user, status: 'BOOKED' });
      await this.bookingRepo.save(booking);
      created.push(booking.id);
    }

    camp.seatsBooked = (camp.seatsBooked || 0) + toBook;
    await this.repo.save(camp);

    return { ok: true, bookingIds: created, count: toBook, remaining: camp.seatsTotal - camp.seatsBooked };
  }

  adminListBookings(campaignId: string) {
    return this.bookingRepo.find({
      where: { campaign: { id: campaignId } },
      order: { createdAt: 'DESC' },
    });
  }
}
