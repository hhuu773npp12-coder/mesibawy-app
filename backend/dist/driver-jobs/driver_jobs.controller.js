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
exports.DriverJobsController = void 0;
const common_1 = require("@nestjs/common");
const driver_jobs_service_1 = require("./driver_jobs.service");
let DriverJobsController = class DriverJobsController {
    svc;
    constructor(svc) {
        this.svc = svc;
    }
    list(role, status) {
        return this.svc.list(role, status);
    }
    accept(id) {
        return this.svc.accept(id);
    }
    reject(id) {
        return this.svc.reject(id);
    }
    complete(id) {
        return this.svc.complete(id);
    }
    notifyAdmin(id) {
        return this.svc.notifyAdminOnReject(id);
    }
    notifyArrived(id) {
        return this.svc.notifyCitizenArrived(id);
    }
    notifyArrivedRestaurant(id) {
        return this.svc.notifyArrivedAtRestaurant(id);
    }
    notifyPickedUp(id, body) {
        return this.svc.notifyPickedUp(id, body?.driverName ?? '');
    }
    notifyArrivedCitizen(id) {
        return this.svc.notifyArrivedToCitizen(id);
    }
};
exports.DriverJobsController = DriverJobsController;
__decorate([
    (0, common_1.Get)('jobs'),
    __param(0, (0, common_1.Query)('role')),
    __param(1, (0, common_1.Query)('status')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], DriverJobsController.prototype, "list", null);
__decorate([
    (0, common_1.Post)(':id/accept'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], DriverJobsController.prototype, "accept", null);
__decorate([
    (0, common_1.Post)(':id/reject'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], DriverJobsController.prototype, "reject", null);
__decorate([
    (0, common_1.Post)(':id/complete'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], DriverJobsController.prototype, "complete", null);
__decorate([
    (0, common_1.Post)(':id/notify-admin-reject'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], DriverJobsController.prototype, "notifyAdmin", null);
__decorate([
    (0, common_1.Post)(':id/notify-arrived'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], DriverJobsController.prototype, "notifyArrived", null);
__decorate([
    (0, common_1.Post)(':id/notify-arrived-restaurant'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], DriverJobsController.prototype, "notifyArrivedRestaurant", null);
__decorate([
    (0, common_1.Post)(':id/notify-picked-up'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", void 0)
], DriverJobsController.prototype, "notifyPickedUp", null);
__decorate([
    (0, common_1.Post)(':id/notify-arrived-citizen'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], DriverJobsController.prototype, "notifyArrivedCitizen", null);
exports.DriverJobsController = DriverJobsController = __decorate([
    (0, common_1.Controller)('driver-jobs'),
    __metadata("design:paramtypes", [driver_jobs_service_1.DriverJobsService])
], DriverJobsController);
//# sourceMappingURL=driver_jobs.controller.js.map