"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.CampaignsService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const campaign_entity_1 = require("./campaign.entity");
const campaign_booking_entity_1 = require("./campaign-booking.entity");
const user_entity_1 = require("../users/user.entity");
const notifications_service_1 = require("../notifications/notifications.service");
let CampaignsService = class CampaignsService {
    repo;
    bookingRepo;
    usersRepo;
    notifications;
    constructor(repo, bookingRepo, usersRepo, notifications) {
        this.repo = repo;
        this.bookingRepo = bookingRepo;
        this.usersRepo = usersRepo;
        this.notifications = notifications;
    }
    create(data) {
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
    async sharePlaceholder(id) {
        const c = await this.repo.findOne({ where: { id } });
        if (!c)
            throw new common_1.NotFoundException('Campaign not found');
        try {
            const data = { kind: 'campaign_share', campaignId: c.id };
            const tags = [{ key: 'role', relation: '=', value: 'kia_passenger' }];
            const sent = await this.notifications?.sendToTags(tags, 'حملة زيارة جديدة', `العنوان: ${c.title} — الانطلاق: ${c.originArea}`, data);
            if (!sent) {
                await this.notifications?.sendToAll('حملة زيارة جديدة', `العنوان: ${c.title} — الانطلاق: ${c.originArea}`, data);
            }
        }
        catch (_) {
        }
        return { ok: true, message: 'تم تجهيز المشاركة وإرسال إشعار (عند التهيئة)', campaignId: id };
    }
    async book(campaignId, userId, count = 1) {
        const camp = await this.repo.findOne({ where: { id: campaignId } });
        if (!camp)
            throw new common_1.NotFoundException('Campaign not found');
        if (!camp.active)
            throw new common_1.BadRequestException('Campaign not active');
        const user = await this.usersRepo.findOne({ where: { id: userId } });
        if (!user)
            throw new common_1.NotFoundException('User not found');
        const remaining = camp.seatsTotal - (camp.seatsBooked || 0);
        const toBook = Math.max(1, Math.floor(count));
        if (remaining <= 0 || remaining < toBook)
            throw new common_1.BadRequestException('No seats available');
        const existing = await this.bookingRepo.findOne({ where: { campaign: { id: campaignId }, user: { id: userId }, status: 'BOOKED' } });
        if (existing)
            throw new common_1.BadRequestException('Already booked');
        const created = [];
        for (let i = 0; i < toBook; i++) {
            const booking = this.bookingRepo.create({ campaign: camp, user, status: 'BOOKED' });
            await this.bookingRepo.save(booking);
            created.push(booking.id);
        }
        camp.seatsBooked = (camp.seatsBooked || 0) + toBook;
        await this.repo.save(camp);
        return { ok: true, bookingIds: created, count: toBook, remaining: camp.seatsTotal - camp.seatsBooked };
    }
    adminListBookings(campaignId) {
        return this.bookingRepo.find({
            where: { campaign: { id: campaignId } },
            order: { createdAt: 'DESC' },
        });
    }
};
exports.CampaignsService = CampaignsService;
exports.CampaignsService = CampaignsService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(campaign_entity_1.Campaign)),
    __param(1, (0, typeorm_1.InjectRepository)(campaign_booking_entity_1.CampaignBooking)),
    __param(2, (0, typeorm_1.InjectRepository)(user_entity_1.User)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository,
        notifications_service_1.NotificationsService])
], CampaignsService);
//# sourceMappingURL=campaigns.service.js.map