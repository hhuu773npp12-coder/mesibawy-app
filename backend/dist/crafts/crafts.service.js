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
exports.CraftsService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const matching_service_1 = require("../matching/matching.service");
const craft_job_entity_1 = require("./entities/craft-job.entity");
const craft_profile_entity_1 = require("./entities/craft-profile.entity");
let CraftsService = class CraftsService {
    matching;
    jobsRepo;
    profilesRepo;
    constructor(matching, jobsRepo, profilesRepo) {
        this.matching = matching;
        this.jobsRepo = jobsRepo;
        this.profilesRepo = profilesRepo;
    }
    async list(role, status) {
        const where = {};
        if (role)
            where['assignee'] = { craftType: role };
        if (status)
            where['status'] = status;
        const qb = this.jobsRepo.createQueryBuilder('j').leftJoinAndSelect('j.assignee', 'a');
        if (status)
            qb.andWhere('j.status = :status', { status });
        if (role)
            qb.andWhere('a.craftType = :role', { role });
        qb.orderBy('j.createdAt', 'DESC');
        const entities = await qb.getMany();
        return entities.map(this.mapEntityToDto);
    }
    async getById(id) {
        const j = await this.jobsRepo.findOne({ where: { id }, relations: ['assignee'] });
        if (!j)
            throw new common_1.BadRequestException('Job not found');
        return this.mapEntityToDto(j);
    }
    async createRequest(input) {
        const entity = this.jobsRepo.create({
            citizenName: input.citizenName,
            citizenPhone: input.citizenPhone,
            address: input.address,
            status: 'PENDING',
            timerSecondsLeft: 0,
            hoursRequested: Math.max(0, Math.floor(input.hours)),
            hoursAdded: 0,
            pricePerHour: Math.max(0, Math.floor(input.pricePerHour)),
        });
        const profile = await this.profilesRepo.findOne({ where: { craftType: input.role } });
        if (profile)
            entity.assignee = profile;
        const saved = await this.jobsRepo.save(entity);
        const fresh = await this.jobsRepo.findOne({ where: { id: saved.id }, relations: ['assignee'] });
        if (!fresh)
            throw new common_1.BadRequestException('Failed to create job');
        return this.mapEntityToDto(fresh);
    }
    async accept(id, craftsman) {
        const j = await this.mustFind(id);
        if (j.status !== 'PENDING')
            throw new common_1.BadRequestException('Invalid state');
        j.status = 'ACCEPTED';
        j.timerSecondsLeft = (j.hoursRequested + j.hoursAdded) * 3600;
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
    async start(id) {
        const j = await this.mustFind(id);
        if (j.status !== 'ACCEPTED' && j.status !== 'PAUSED')
            throw new common_1.BadRequestException('Invalid state');
        if (!j.timerSecondsLeft || j.timerSecondsLeft <= 0)
            j.timerSecondsLeft = (j.hoursRequested + j.hoursAdded) * 3600;
        j.status = 'IN_PROGRESS';
        await this.jobsRepo.save(j);
        return this.mapEntityToDto(j);
    }
    async pause(id) {
        const j = await this.mustFind(id);
        if (j.status !== 'IN_PROGRESS')
            throw new common_1.BadRequestException('Invalid state');
        j.status = 'PAUSED';
        await this.jobsRepo.save(j);
        return this.mapEntityToDto(j);
    }
    async resume(id) {
        return this.start(id);
    }
    async addHours(id, hours) {
        if (!Number.isFinite(hours) || hours <= 0)
            throw new common_1.BadRequestException('Invalid hours');
        const j = await this.mustFind(id);
        j.hoursAdded += Math.floor(hours);
        if (j.timerSecondsLeft && j.timerSecondsLeft > 0)
            j.timerSecondsLeft += Math.floor(hours * 3600);
        await this.jobsRepo.save(j);
        return this.mapEntityToDto(j);
    }
    async cancelByCitizen(id) {
        const j = await this.mustFind(id);
        if (j.status === 'IN_PROGRESS' || j.status === 'COMPLETED' || j.status === 'REJECTED') {
            throw new common_1.BadRequestException('Cannot cancel at this stage');
        }
        j.status = 'REJECTED';
        await this.jobsRepo.save(j);
        return { ok: true };
    }
    async complete(id) {
        const j = await this.mustFind(id);
        if (j.status === 'REJECTED' || j.status === 'COMPLETED')
            throw new common_1.BadRequestException('Invalid state');
        j.status = 'COMPLETED';
        await this.jobsRepo.save(j);
        const totalHours = j.hoursRequested + j.hoursAdded;
        const totalPrice = totalHours * j.pricePerHour;
        const commission = Math.floor(totalPrice * 0.1);
        return { ok: true, totalHours, totalPrice, commission };
    }
    async notify(id, message) {
        const j = await this.mustFind(id);
        return { ok: true, to: j.citizenPhone, message };
    }
    async mustFind(id) {
        const j = await this.jobsRepo.findOne({ where: { id }, relations: ['assignee'] });
        if (!j)
            throw new common_1.BadRequestException('Job not found');
        return j;
    }
    rankCandidates(candidates, opts) {
        return this.matching.filterAndRankCandidates(candidates, opts);
    }
    mapEntityToDto = (e) => ({
        id: e.id,
        role: e.assignee?.craftType ?? 'electrician',
        citizenName: e.citizenName,
        citizenPhone: e.citizenPhone,
        address: e.address,
        hoursRequested: e.hoursRequested,
        hoursAdded: e.hoursAdded,
        pricePerHour: e.pricePerHour,
        status: e.status,
        timerSecondsLeft: e.timerSecondsLeft ?? 0,
    });
};
exports.CraftsService = CraftsService;
exports.CraftsService = CraftsService = __decorate([
    (0, common_1.Injectable)(),
    __param(1, (0, typeorm_1.InjectRepository)(craft_job_entity_1.CraftJob)),
    __param(2, (0, typeorm_1.InjectRepository)(craft_profile_entity_1.CraftProfile)),
    __metadata("design:paramtypes", [matching_service_1.MatchingService,
        typeorm_2.Repository,
        typeorm_2.Repository])
], CraftsService);
//# sourceMappingURL=crafts.service.js.map