import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Order } from './order.entity';
import { PricingService, Category } from '../pricing/pricing.service';
import { User } from '../users/user.entity';
import { RestaurantOffer } from '../restaurants/restaurant-offer.entity';

@Injectable()
export class OrdersService {
  constructor(
    @InjectRepository(Order) private readonly repo: Repository<Order>,
    @InjectRepository(User) private readonly usersRepo: Repository<User>,
    @InjectRepository(RestaurantOffer) private readonly offersRepo: Repository<RestaurantOffer>,
    private readonly pricing: PricingService,
  ) {}

  async estimateAndCreate(input: { userId?: string; category: Category; distanceKm: number; durationMin?: number }) {
    const est = this.pricing.estimate({
      category: input.category,
      distanceKm: input.distanceKm,
      durationMin: input.durationMin,
    });

    let user: User | null = null;
    if (input.userId) {
      user = await this.usersRepo.findOne({ where: { id: input.userId } });
      if (!user) throw new NotFoundException('User not found');
    }

    const order = this.repo.create({
      user,
      category: input.category,
      distanceKm: input.distanceKm,
      durationMin: input.durationMin ?? null,
      priceTotal: est.total,
      currency: est.currency,
      breakdown: est.breakdown,
      status: 'CREATED',
    });
    const saved = await this.repo.save(order);
    return { order: saved, estimate: est };
  }

  listAdmin(limit = 100, filters?: { category?: string; status?: string; dateFrom?: string; dateTo?: string }) {
    const where: any = {};
    if (filters?.category) where.category = filters.category;
    if (filters?.status) where.status = filters.status;

    const findOpts: any = {
      where,
      order: { createdAt: 'DESC' },
      take: limit,
    };

    if (filters?.dateFrom || filters?.dateTo) {
      const from = filters?.dateFrom ? new Date(filters.dateFrom) : undefined;
      const to = filters?.dateTo ? new Date(filters.dateTo) : undefined;
      // TypeORM Between/MoreThan/LessThan alternative via query builder for createdAt range
      const qb = this.repo.createQueryBuilder('o').leftJoinAndSelect('o.user', 'user');
      qb.orderBy('o.createdAt', 'DESC').limit(limit);
      if (where.category) qb.andWhere('o.category = :cat', { cat: where.category });
      if (where.status) qb.andWhere('o.status = :st', { st: where.status });
      if (from) qb.andWhere('o.createdAt >= :from', { from });
      if (to) qb.andWhere('o.createdAt <= :to', { to });
      return qb.getMany();
    }

    return this.repo.find(findOpts);
  }

  // Food orders
  async createFoodOrder(userId: string, input: { offerId: string; quantity: number; notes?: string }) {
    const user = await this.usersRepo.findOne({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');
    const offer = await this.offersRepo.findOne({ where: { id: input.offerId } });
    if (!offer) throw new NotFoundException('Offer not found');
    if (!input.quantity || input.quantity < 1) throw new BadRequestException('Quantity must be >= 1');

    const priceTotal = offer.price * input.quantity;
    const breakdown = {
      kind: 'food',
      offerId: offer.id,
      offerName: offer.name,
      unitPrice: offer.price,
      quantity: input.quantity,
      notes: input.notes ?? null,
      restaurantOwnerId: offer.ownerUserId,
      stage: 'pending', // pending | accepted | preparing | delivering | completed | rejected
    };

    const order = this.repo.create({
      user,
      category: 'food',
      distanceKm: 0,
      durationMin: null,
      priceTotal,
      currency: 'IQD',
      breakdown,
      status: 'CREATED',
    });
    return this.repo.save(order);
  }

  async listRestaurantOrders(ownerUserId: string, stage?: string) {
    // filter by breakdown.restaurantOwnerId and optional stage
    const qb = this.repo.createQueryBuilder('o');
    qb.where("o.category = :cat", { cat: 'food' });
    qb.andWhere("(o.breakdown->>'restaurantOwnerId') = :oid", { oid: ownerUserId });
    if (stage) qb.andWhere("(o.breakdown->>'stage') = :st", { st: stage });
    qb.orderBy('o.createdAt', 'DESC');
    return qb.getMany();
  }

  async updateRestaurantOrderStage(orderId: string, stage: 'accepted' | 'preparing' | 'delivering' | 'completed' | 'rejected') {
    const order = await this.repo.findOne({ where: { id: orderId } });
    if (!order) throw new NotFoundException('Order not found');
    if (order.category !== 'food') throw new BadRequestException('Not a food order');
    const breakdown = { ...(order.breakdown || {}) };
    breakdown.stage = stage;
    order.breakdown = breakdown;
    if (stage === 'completed') order.status = 'COMPLETED';
    if (stage === 'rejected') order.status = 'CANCELLED';
    return this.repo.save(order);
  }

  async getByIdForUser(userId: string, orderId: string) {
    const order = await this.repo.findOne({ where: { id: orderId } });
    if (!order) throw new NotFoundException('Order not found');
    if (!order.user || order.user.id !== userId) throw new NotFoundException('Order not found');
    return order;
  }
}
