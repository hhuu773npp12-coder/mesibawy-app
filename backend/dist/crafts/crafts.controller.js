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
exports.CraftsController = void 0;
const common_1 = require("@nestjs/common");
const crafts_service_1 = require("./crafts.service");
let CraftsController = class CraftsController {
    crafts;
    constructor(crafts) {
        this.crafts = crafts;
    }
    list(role, status) {
        return this.crafts.list(role, status);
    }
    create(body) {
        return this.crafts.createRequest(body);
    }
    getOne(id) {
        return this.crafts.getById(id);
    }
    accept(id, body) {
        return this.crafts.accept(id, { name: body?.craftsmanName, phone: body?.craftsmanPhone });
    }
    reject(id) {
        return this.crafts.reject(id);
    }
    start(id) {
        return this.crafts.start(id);
    }
    pause(id) {
        return this.crafts.pause(id);
    }
    resume(id) {
        return this.crafts.resume(id);
    }
    addHours(id, body) {
        return this.crafts.addHours(id, body.hours);
    }
    addHoursCitizen(id, body) {
        return this.crafts.addHours(id, body.hours);
    }
    complete(id) {
        return this.crafts.complete(id);
    }
    cancel(id) {
        return this.crafts.cancelByCitizen(id);
    }
    notify(id, body) {
        return this.crafts.notify(id, body.message);
    }
};
exports.CraftsController = CraftsController;
__decorate([
    (0, common_1.Get)('jobs'),
    __param(0, (0, common_1.Query)('role')),
    __param(1, (0, common_1.Query)('status')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], CraftsController.prototype, "list", null);
__decorate([
    (0, common_1.Post)(),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], CraftsController.prototype, "create", null);
__decorate([
    (0, common_1.Get)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], CraftsController.prototype, "getOne", null);
__decorate([
    (0, common_1.Post)(':id/accept'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", void 0)
], CraftsController.prototype, "accept", null);
__decorate([
    (0, common_1.Post)(':id/reject'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], CraftsController.prototype, "reject", null);
__decorate([
    (0, common_1.Post)(':id/start'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], CraftsController.prototype, "start", null);
__decorate([
    (0, common_1.Post)(':id/pause'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], CraftsController.prototype, "pause", null);
__decorate([
    (0, common_1.Post)(':id/resume'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], CraftsController.prototype, "resume", null);
__decorate([
    (0, common_1.Post)(':id/add-hours'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", void 0)
], CraftsController.prototype, "addHours", null);
__decorate([
    (0, common_1.Post)(':id/add-hours-citizen'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", void 0)
], CraftsController.prototype, "addHoursCitizen", null);
__decorate([
    (0, common_1.Post)(':id/complete'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], CraftsController.prototype, "complete", null);
__decorate([
    (0, common_1.Post)(':id/cancel'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], CraftsController.prototype, "cancel", null);
__decorate([
    (0, common_1.Post)(':id/notify'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", void 0)
], CraftsController.prototype, "notify", null);
exports.CraftsController = CraftsController = __decorate([
    (0, common_1.Controller)('crafts'),
    __metadata("design:paramtypes", [crafts_service_1.CraftsService])
], CraftsController);
//# sourceMappingURL=crafts.controller.js.map