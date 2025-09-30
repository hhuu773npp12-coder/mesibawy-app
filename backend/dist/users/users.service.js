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
exports.UsersService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const user_entity_1 = require("./user.entity");
let UsersService = class UsersService {
    repo;
    constructor(repo) {
        this.repo = repo;
    }
    generateUserId() {
        const rand = Math.random().toString(36).slice(2, 8).toUpperCase();
        return `U${Date.now().toString(36).toUpperCase()}${rand}`;
    }
    async create(dto) {
        const user = this.repo.create({
            ...dto,
            userId: this.generateUserId(),
            isApproved: false,
            isActive: true,
            walletBalance: 0,
        });
        return this.repo.save(user);
    }
    findAll() {
        return this.repo.find({ order: { createdAt: 'DESC' } });
    }
    async findOne(id) {
        const user = await this.repo.findOne({ where: { id } });
        if (!user)
            throw new common_1.NotFoundException('User not found');
        return user;
    }
    async update(id, dto) {
        const user = await this.findOne(id);
        Object.assign(user, dto);
        return this.repo.save(user);
    }
    async updateLocation(id, lastLat, lastLng) {
        const user = await this.findOne(id);
        if (typeof lastLat === 'number')
            user.lastLat = lastLat;
        if (typeof lastLng === 'number')
            user.lastLng = lastLng;
        return this.repo.save(user);
    }
    async findActiveCandidatesByRoles(roles, minWallet = 0) {
        const users = await this.repo.find({ where: roles.map((r) => ({ role: r })) });
        return users
            .filter((u) => u.isActive && (u.walletBalance ?? 0) >= minWallet && typeof u.lastLat === 'number' && typeof u.lastLng === 'number')
            .map((u) => ({ id: u.id, active: u.isActive, walletBalance: u.walletBalance ?? 0, lat: u.lastLat, lng: u.lastLng }));
    }
    async remove(id) {
        const user = await this.findOne(id);
        await this.repo.remove(user);
    }
};
exports.UsersService = UsersService;
exports.UsersService = UsersService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(user_entity_1.User)),
    __metadata("design:paramtypes", [typeorm_2.Repository])
], UsersService);
//# sourceMappingURL=users.service.js.map