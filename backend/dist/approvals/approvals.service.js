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
exports.ApprovalsService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const approval_entity_1 = require("./approval.entity");
const user_entity_1 = require("../users/user.entity");
let ApprovalsService = class ApprovalsService {
    repo;
    usersRepo;
    constructor(repo, usersRepo) {
        this.repo = repo;
        this.usersRepo = usersRepo;
    }
    async list(status) {
        if (status)
            return this.repo.find({ where: { status }, order: { createdAt: 'DESC' } });
        return this.repo.find({ order: { createdAt: 'DESC' } });
    }
    async createForUser(userId) {
        const user = await this.usersRepo.findOne({ where: { id: userId } });
        if (!user)
            throw new common_1.NotFoundException('User not found');
        const approval = this.repo.create({ user, status: 'PENDING' });
        return this.repo.save(approval);
    }
    async approve(id, adminId, note) {
        const approval = await this.repo.findOne({ where: { id } });
        if (!approval)
            throw new common_1.NotFoundException('Approval not found');
        approval.status = 'APPROVED';
        approval.decidedByAdminId = adminId;
        approval.note = note ?? null;
        if (approval.user) {
            approval.user.isApproved = true;
            await this.usersRepo.save(approval.user);
        }
        return this.repo.save(approval);
    }
    async reject(id, adminId, note) {
        const approval = await this.repo.findOne({ where: { id } });
        if (!approval)
            throw new common_1.NotFoundException('Approval not found');
        approval.status = 'REJECTED';
        approval.decidedByAdminId = adminId;
        approval.note = note ?? null;
        if (approval.user && approval.user.isApproved) {
            approval.user.isApproved = false;
            await this.usersRepo.save(approval.user);
        }
        return this.repo.save(approval);
    }
};
exports.ApprovalsService = ApprovalsService;
exports.ApprovalsService = ApprovalsService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(approval_entity_1.Approval)),
    __param(1, (0, typeorm_1.InjectRepository)(user_entity_1.User)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository])
], ApprovalsService);
//# sourceMappingURL=approvals.service.js.map