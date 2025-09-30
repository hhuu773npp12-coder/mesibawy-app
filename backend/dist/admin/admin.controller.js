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
exports.AdminController = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const user_entity_1 = require("../users/user.entity");
const verification_code_entity_1 = require("../auth/verification-code.entity");
const approvals_service_1 = require("../approvals/approvals.service");
const jwt_auth_guard_1 = require("../auth/jwt-auth.guard");
const roles_guard_1 = require("../auth/roles.guard");
const roles_decorator_1 = require("../auth/roles.decorator");
class DecisionBody {
    adminId;
    note;
}
let AdminController = class AdminController {
    approvals;
    usersRepo;
    codesRepo;
    constructor(approvals, usersRepo, codesRepo) {
        this.approvals = approvals;
        this.usersRepo = usersRepo;
        this.codesRepo = codesRepo;
    }
    listApprovals(status) {
        return this.approvals.list(status);
    }
    approve(id, body) {
        return this.approvals.approve(id, body.adminId, body.note);
    }
    reject(id, body) {
        return this.approvals.reject(id, body.adminId, body.note);
    }
    listCodes(phone) {
        const where = phone ? { phone } : {};
        return this.codesRepo.find({ where, order: { createdAt: 'DESC' }, take: 50 });
    }
    async listUsers(role, approved, q) {
        const where = {};
        if (role)
            where.role = role;
        if (approved === 'true')
            where.isApproved = true;
        if (approved === 'false')
            where.isApproved = false;
        if (q && q.trim()) {
            const term = `%${q.trim()}%`;
            return this.usersRepo.find({
                where: [
                    { ...where, name: (0, typeorm_2.ILike)(term) },
                    { ...where, phone: (0, typeorm_2.ILike)(term) },
                ],
                order: { createdAt: 'DESC' },
                take: 100,
            });
        }
        return this.usersRepo.find({ where, order: { createdAt: 'DESC' }, take: 100 });
    }
    async setUserRole(id, body) {
        await this.usersRepo.update({ id }, { role: body.role });
        return this.usersRepo.findOne({ where: { id } });
    }
    async setUserApproval(id, body) {
        await this.usersRepo.update({ id }, { isApproved: !!body.approved });
        return this.usersRepo.findOne({ where: { id } });
    }
};
exports.AdminController = AdminController;
__decorate([
    (0, common_1.Get)('approvals'),
    __param(0, (0, common_1.Query)('status')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "listApprovals", null);
__decorate([
    (0, common_1.Patch)('approvals/:id/approve'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, DecisionBody]),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "approve", null);
__decorate([
    (0, common_1.Patch)('approvals/:id/reject'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, DecisionBody]),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "reject", null);
__decorate([
    (0, common_1.Get)('codes'),
    __param(0, (0, common_1.Query)('phone')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "listCodes", null);
__decorate([
    (0, common_1.Get)('users'),
    __param(0, (0, common_1.Query)('role')),
    __param(1, (0, common_1.Query)('approved')),
    __param(2, (0, common_1.Query)('q')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, String]),
    __metadata("design:returntype", Promise)
], AdminController.prototype, "listUsers", null);
__decorate([
    (0, common_1.Patch)('users/:id/role'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], AdminController.prototype, "setUserRole", null);
__decorate([
    (0, common_1.Patch)('users/:id/approve'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], AdminController.prototype, "setUserApproval", null);
exports.AdminController = AdminController = __decorate([
    (0, common_1.Controller)('admin'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, roles_guard_1.RolesGuard),
    (0, roles_decorator_1.Roles)('admin', 'owner'),
    __param(1, (0, typeorm_1.InjectRepository)(user_entity_1.User)),
    __param(2, (0, typeorm_1.InjectRepository)(verification_code_entity_1.VerificationCode)),
    __metadata("design:paramtypes", [approvals_service_1.ApprovalsService,
        typeorm_2.Repository,
        typeorm_2.Repository])
], AdminController);
//# sourceMappingURL=admin.controller.js.map