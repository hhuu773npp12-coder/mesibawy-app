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
exports.WalletsController = void 0;
const common_1 = require("@nestjs/common");
const wallets_service_1 = require("./wallets.service");
const jwt_auth_guard_1 = require("../auth/jwt-auth.guard");
let WalletsController = class WalletsController {
    wallets;
    constructor(wallets) {
        this.wallets = wallets;
    }
    getBalance(userId) {
        return this.wallets.getBalance(userId);
    }
    list(userId) {
        return this.wallets.listTransactions(userId);
    }
    credit(userId, body) {
        return this.wallets.addTransaction(userId, Math.abs(body.amount), 'CREDIT', body.reference);
    }
    debit(userId, body) {
        return this.wallets.addTransaction(userId, -Math.abs(body.amount), 'DEBIT', body.reference);
    }
    topupMe(req, body) {
        const userId = req.user?.sub;
        return this.wallets.topupByCode(userId, (body.code || '').toString());
    }
};
exports.WalletsController = WalletsController;
__decorate([
    (0, common_1.Get)(':userId/balance'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], WalletsController.prototype, "getBalance", null);
__decorate([
    (0, common_1.Get)(':userId/transactions'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], WalletsController.prototype, "list", null);
__decorate([
    (0, common_1.Post)(':userId/credit'),
    __param(0, (0, common_1.Param)('userId')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", void 0)
], WalletsController.prototype, "credit", null);
__decorate([
    (0, common_1.Post)(':userId/debit'),
    __param(0, (0, common_1.Param)('userId')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", void 0)
], WalletsController.prototype, "debit", null);
__decorate([
    (0, common_1.Post)('me/topup'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", void 0)
], WalletsController.prototype, "topupMe", null);
exports.WalletsController = WalletsController = __decorate([
    (0, common_1.Controller)('wallets'),
    __metadata("design:paramtypes", [wallets_service_1.WalletsService])
], WalletsController);
//# sourceMappingURL=wallets.controller.js.map