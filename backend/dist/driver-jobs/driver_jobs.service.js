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
exports.DriverJobsService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const matching_service_1 = require("../matching/matching.service");
const owner_service_1 = require("../owner/owner.service");
const driver_job_entity_1 = require("./entities/driver-job.entity");
let DriverJobsService = class DriverJobsService {
    owner;
    matching;
    jobsRepo;
    constructor(owner, matching, jobsRepo) {
        this.owner = owner;
        this.matching = matching;
        this.jobsRepo = jobsRepo;
    }
    async list(role, status) {
        const where = {};
        if (role)
            where.role = role;
        if (status)
            where.status = status;
        const entities = await this.jobsRepo.find({ where, order: { createdAt: 'DESC' } });
        return entities.map(this.mapEntityToDto);
    }
    async accept(id) {
        const j = await this.mustFind(id);
        if (j.status !== 'PENDING')
            throw new common_1.BadRequestException('Invalid state');
        j.status = 'ACCEPTED';
        await this.jobsRepo.save(j);
        return this.mapEntityToDto(j);
    }
    async reject(id) {
        const j = await this.mustFind(id);
        if (j.status === 'COMPLETED' || j.status === 'REJECTED')
            throw new common_1.BadRequestException('Invalid state');
        j.status = 'REJECTED';
        await this.jobsRepo.save(j);
        return { ok: true };
    }
    async complete(id) {
        const j = await this.mustFind(id);
        if (j.status !== 'ACCEPTED')
            throw new common_1.BadRequestException('Invalid state');
        j.status = 'COMPLETED';
        await this.jobsRepo.save(j);
        let commission = 0;
        let total = j.price;
        if (j.role === 'bike') {
            const totalPrice = j.totalPrice ?? 0;
            const deliveryPrice = j.deliveryPrice ?? 0;
            commission = Math.max(0, Math.floor(totalPrice - deliveryPrice * 0.9));
            total = totalPrice;
        }
        else {
            commission = Math.floor(j.price * 0.1);
            total = j.price;
        }
        this.owner.addToWallet(commission);
        return { ok: true, totalPrice: total, commission };
    }
    async notifyAdminOnReject(id) {
        const j = await this.mustFind(id);
        return { ok: true, to: 'admin', jobId: j.id, message: 'تم رفض الرحلة من السائق' };
    }
    async notifyCitizenArrived(id) {
        const j = await this.mustFind(id);
        return { ok: true, to: j.citizenPhone, message: 'لقد وصل السائق إلى نقطة الانطلاق' };
    }
    async notifyArrivedAtRestaurant(id) {
        const j = await this.mustFind(id);
        return { ok: true, to: j.citizenPhone, message: 'وصل السائق إلى المطعم' };
    }
    async notifyPickedUp(id, driverName) {
        const j = await this.mustFind(id);
        const name = driverName?.trim() || 'السائق';
        return { ok: true, to: j.citizenPhone, message: `تم استلام طلبك من قبل ${name}` };
    }
    async notifyArrivedToCitizen(id) {
        const j = await this.mustFind(id);
        return { ok: true, to: j.citizenPhone, message: 'تم وصول السائق إلى موقعك' };
    }
    async mustFind(id) {
        const j = await this.jobsRepo.findOne({ where: { id } });
        if (!j)
            throw new common_1.BadRequestException('Job not found');
        return j;
    }
    rankDrivers(candidates, opts) {
        return this.matching.filterAndRankCandidates(candidates, {
            jobLat: opts.startLat,
            jobLng: opts.startLng,
            maxRadiusKm: opts.maxRadiusKm,
            minWallet: opts.minWallet,
            limit: opts.limit,
        });
    }
    enforceBikePriceCap(totalPriceIqD) {
        return totalPriceIqD <= 40000;
    }
    mapEntityToDto = (e) => ({
        id: e.id,
        role: e.role,
        citizenName: e.citizenName,
        citizenPhone: e.citizenPhone,
        price: e.price,
        totalPrice: e.totalPrice ?? undefined,
        deliveryPrice: e.deliveryPrice ?? undefined,
        startLat: e.startLat,
        startLng: e.startLng,
        destLat: e.destLat,
        destLng: e.destLng,
        status: e.status,
    });
};
exports.DriverJobsService = DriverJobsService;
exports.DriverJobsService = DriverJobsService = __decorate([
    (0, common_1.Injectable)(),
    __param(2, (0, typeorm_1.InjectRepository)(driver_job_entity_1.DriverJob)),
    __metadata("design:paramtypes", [owner_service_1.OwnerService,
        matching_service_1.MatchingService,
        typeorm_2.Repository])
], DriverJobsService);
//# sourceMappingURL=driver_jobs.service.js.map