import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { RestaurantOffer } from './restaurant-offer.entity';
import { RestaurantOrder, RestaurantOrderStage } from './restaurant-order.entity';
import { RestaurantOrderItem } from './restaurant-order-item.entity';

@Injectable()
export class RestaurantsService {
  constructor(
    @InjectRepository(RestaurantOffer) private readonly offersRepo: Repository<RestaurantOffer>,
    @InjectRepository(RestaurantOrder) private readonly ordersRepo: Repository<RestaurantOrder>,
    @InjectRepository(RestaurantOrderItem) private readonly orderItemsRepo: Repository<RestaurantOrderItem>,
  ) {}

  listMyOffers(ownerUserId: string) {
    return this.offersRepo.find({ where: { ownerUserId }, order: { createdAt: 'DESC' } });
  }

  async createOffer(ownerUserId: string, dto: { name: string; price: number; imageUrl: string }) {
    const entity = this.offersRepo.create({ ownerUserId, name: dto.name, price: dto.price, imageUrl: dto.imageUrl });
    return this.offersRepo.save(entity);
  }

  // Delivery fee tiers:
  // 0-3km: 1000, >3-5km: 2000, >5-8km: 3000, >8-12km: 4000, >12-15km: 5000
  private computeDelivery(distanceKm: number): number {
    if (!Number.isFinite(distanceKm) || distanceKm <= 0) return 0;
    if (distanceKm <= 3) return 1000;
    if (distanceKm <= 5) return 2000;
    if (distanceKm <= 8) return 3000;
    if (distanceKm <= 12) return 4000;
    if (distanceKm <= 15) return 5000;
    // beyond 15km, add 500 per extra 3km block
    const extraBlocks = Math.ceil((distanceKm - 15) / 3);
    return 5000 + extraBlocks * 500;
  }

  private haversineKm(aLat: number, aLng: number, bLat: number, bLng: number): number {
    const toRad = (d: number) => (d * Math.PI) / 180;
    const R = 6371; // km
    const dLat = toRad(bLat - aLat);
    const dLng = toRad(bLng - aLng);
    const lat1 = toRad(aLat);
    const lat2 = toRad(bLat);
    const h = Math.sin(dLat / 2) ** 2 + Math.sin(dLng / 2) ** 2 * Math.cos(lat1) * Math.cos(lat2);
    return 2 * R * Math.asin(Math.sqrt(h));
  }

  async createPublicOrder(input: {
    customerName?: string;
    customerPhone?: string;
    items: { offerId: string; qty: number }[];
    distanceKm?: number;
    restaurantLat?: number;
    restaurantLng?: number;
    customerLat?: number;
    customerLng?: number;
  }) {
    if (!input.items || !input.items.length) throw new BadRequestException('No items');
    // Load offers and validate single-restaurant constraint
    const offerIds = input.items.map((i) => i.offerId);
    const offers = await this.offersRepo.findByIds(offerIds);
    if (offers.length !== offerIds.length) throw new BadRequestException('Invalid offer');
    const ownerUserId = offers[0].ownerUserId;
    if (!offers.every((o) => o.ownerUserId === ownerUserId)) throw new BadRequestException('Items must belong to the same restaurant');

    // Build order items with captured price
    const items: RestaurantOrderItem[] = [];
    let itemsTotal = 0;
    for (const it of input.items) {
      const offer = offers.find((o) => o.id === it.offerId)!;
      const qty = Math.max(1, Math.floor(it.qty));
      const price = offer.price;
      itemsTotal += price * qty;
      items.push(this.orderItemsRepo.create({ offer, qty, price }));
    }

    // Delivery calculation
    let delivery = 0;
    if (Number.isFinite(input?.distanceKm as number)) {
      delivery = this.computeDelivery(input.distanceKm as number);
    } else if (
      Number.isFinite(input?.customerLat as number) &&
      Number.isFinite(input?.customerLng as number)
    ) {
      // Prefer restaurant coordinates from offers (if present), else from input
      const restLat = (offers[0] as any).restaurantLat ?? input.restaurantLat;
      const restLng = (offers[0] as any).restaurantLng ?? input.restaurantLng;
      if (Number.isFinite(restLat) && Number.isFinite(restLng)) {
        const d = this.haversineKm(restLat as number, restLng as number, input.customerLat as number, input.customerLng as number);
        delivery = this.computeDelivery(d);
      }
    }

    const commission = Math.round(itemsTotal * 0.10);

    const order = this.ordersRepo.create({
      ownerUserId,
      customerName: input.customerName,
      customerPhone: input.customerPhone,
      stage: 'PENDING',
      itemsTotal,
      commission,
      delivery,
      items,
    });
    return this.ordersRepo.save(order);
  }

  listOrders(ownerUserId: string, stage?: RestaurantOrderStage) {
    const where: any = { ownerUserId };
    if (stage) where.stage = stage;
    return this.ordersRepo.find({ where, order: { createdAt: 'DESC' }, relations: ['items', 'items.offer'] });
  }

  async updateOrderStage(ownerUserId: string, id: string, stage: RestaurantOrderStage) {
    const order = await this.ordersRepo.findOne({ where: { id, ownerUserId } });
    if (!order) throw new NotFoundException('Order not found');
    order.stage = stage;
    await this.ordersRepo.save(order);
    return { ok: true };
  }
}
