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
exports.AuthService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const verification_code_entity_1 = require("./verification-code.entity");
const jwt_1 = require("@nestjs/jwt");
const user_entity_1 = require("../users/user.entity");
const config_1 = require("@nestjs/config");
let AuthService = class AuthService {
    codesRepo;
    usersRepo;
    jwt;
    config;
    constructor(codesRepo, usersRepo, jwt, config) {
        this.codesRepo = codesRepo;
        this.usersRepo = usersRepo;
        this.jwt = jwt;
        this.config = config;
    }
    generate4Digit() {
        return Math.floor(1000 + Math.random() * 9000).toString();
    }
    async requestCode(phone, intendedRole, name) {
        const now = new Date();
        const expires = new Date(now.getTime() + 5 * 60 * 1000);
        await this.codesRepo.update({ phone, used: false }, { used: true });
        const code = this.generate4Digit();
        const vc = this.codesRepo.create({ phone, code, expiresAt: expires, used: false, intendedRole: intendedRole ?? null, name: name ?? null });
        const saved = await this.codesRepo.save(vc);
        return { id: saved.id, phone, code, expiresAt: saved.expiresAt };
    }
    async verify(phone, code, intendedRole, name) {
        const existing = await this.codesRepo.findOne({ where: { phone, code } });
        if (!existing)
            throw new common_1.NotFoundException('Invalid code');
        if (existing.used)
            throw new common_1.BadRequestException('Code already used');
        if (existing.expiresAt.getTime() < Date.now())
            throw new common_1.BadRequestException('Code expired');
        existing.used = true;
        await this.codesRepo.save(existing);
        let user = await this.usersRepo.findOne({ where: { phone } });
        if (!user) {
            const role = (existing.intendedRole || intendedRole) || 'citizen';
            user = this.usersRepo.create({
                phone,
                name: (existing.name || name || 'مستخدم'),
                role,
                userId: `U${Date.now().toString(36).toUpperCase()}`,
                isApproved: false,
                isActive: true,
                walletBalance: 0,
            });
            user = await this.usersRepo.save(user);
        }
        const payload = { sub: user.id, phone: user.phone, role: user.role };
        const token = await this.jwt.signAsync(payload);
        return { token, user };
    }
    get adminSecrets() {
        const raw = this.config.get('ADMIN_SECRETS', '') || '';
        const list = raw.split(',').map((s) => s.trim()).filter(Boolean);
        return list.length ? list : ['914206'];
    }
    get ownerSecrets() {
        const raw = this.config.get('OWNER_SECRETS', '') || '';
        const list = raw.split(',').map((s) => s.trim()).filter(Boolean);
        return list.length ? list : ['519740'];
    }
    async adminOwnerLogin(input) {
        const { name, phone, role, secret } = input;
        const list = role === 'admin' ? this.adminSecrets : this.ownerSecrets;
        if (!list.includes(secret))
            throw new common_1.BadRequestException('Invalid secret');
        const max = role === 'admin' ? 10 : 2;
        const count = await this.usersRepo.count({ where: { role } });
        let user = await this.usersRepo.findOne({ where: { phone } });
        if (!user) {
            if (count >= max)
                throw new common_1.BadRequestException('Max accounts reached for role');
            user = this.usersRepo.create({
                phone,
                name: name || 'مستخدم',
                role: role,
                userId: `U${Date.now().toString(36).toUpperCase()}`,
                isApproved: true,
                isActive: true,
                walletBalance: 0,
            });
            user = await this.usersRepo.save(user);
        }
        else {
            user.role = role;
            user.name = name || user.name;
            user.isApproved = true;
            await this.usersRepo.save(user);
        }
        const payload = { sub: user.id, phone: user.phone, role: user.role };
        const token = await this.jwt.signAsync(payload);
        return { token, user };
    }
};
exports.AuthService = AuthService;
exports.AuthService = AuthService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(verification_code_entity_1.VerificationCode)),
    __param(1, (0, typeorm_1.InjectRepository)(user_entity_1.User)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository,
        jwt_1.JwtService,
        config_1.ConfigService])
], AuthService);
//# sourceMappingURL=auth.service.js.map