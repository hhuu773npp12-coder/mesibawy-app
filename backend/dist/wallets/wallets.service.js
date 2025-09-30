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
exports.WalletsService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const wallet_transaction_entity_1 = require("./wallet-transaction.entity");
const user_entity_1 = require("../users/user.entity");
const topup_card_entity_1 = require("../cards/topup-card.entity");
let WalletsService = class WalletsService {
    txRepo;
    usersRepo;
    cardsRepo;
    constructor(txRepo, usersRepo, cardsRepo) {
        this.txRepo = txRepo;
        this.usersRepo = usersRepo;
        this.cardsRepo = cardsRepo;
    }
    async getBalance(userId) {
        const user = await this.usersRepo.findOne({ where: { id: userId } });
        if (!user)
            throw new common_1.NotFoundException('User not found');
        return { balance: user.walletBalance };
    }
    async listTransactions(userId) {
        const user = await this.usersRepo.findOne({ where: { id: userId } });
        if (!user)
            throw new common_1.NotFoundException('User not found');
        return this.txRepo.find({ where: { user }, order: { createdAt: 'DESC' } });
    }
    async addTransaction(userId, amount, type, reference) {
        const user = await this.usersRepo.findOne({ where: { id: userId } });
        if (!user)
            throw new common_1.NotFoundException('User not found');
        user.walletBalance = (user.walletBalance || 0) + amount;
        await this.usersRepo.save(user);
        const tx = this.txRepo.create({ user, amount, type, reference: reference ?? null });
        const transaction = await this.txRepo.save(tx);
        return { balance: user.walletBalance, transaction };
    }
    async topupByCode(userId, code) {
        const user = await this.usersRepo.findOne({ where: { id: userId } });
        if (!user)
            throw new common_1.NotFoundException('User not found');
        const normalized = (code || '').trim();
        const card = await this.cardsRepo.findOne({ where: { code: normalized, used: false } });
        if (!card) {
            throw new Error('Invalid or used topup code');
        }
        card.used = true;
        card.usedByUserId = userId;
        await this.cardsRepo.save(card);
        const amount = Math.max(0, card.amount || 0);
        const { balance } = await this.addTransaction(userId, amount, 'TOPUP', normalized);
        return { balance, added: amount };
    }
};
exports.WalletsService = WalletsService;
exports.WalletsService = WalletsService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(wallet_transaction_entity_1.WalletTransaction)),
    __param(1, (0, typeorm_1.InjectRepository)(user_entity_1.User)),
    __param(2, (0, typeorm_1.InjectRepository)(topup_card_entity_1.TopupCard)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository])
], WalletsService);
//# sourceMappingURL=wallets.service.js.map