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
Object.defineProperty(exports, "__esModule", { value: true });
exports.CraftJob = void 0;
const typeorm_1 = require("typeorm");
const craft_profile_entity_1 = require("./craft-profile.entity");
let CraftJob = class CraftJob {
    id;
    citizenName;
    citizenPhone;
    address;
    status;
    timerSecondsLeft;
    hoursRequested;
    hoursAdded;
    pricePerHour;
    createdAt;
    assignee;
};
exports.CraftJob = CraftJob;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)('uuid'),
    __metadata("design:type", String)
], CraftJob.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'varchar', length: 120 }),
    __metadata("design:type", String)
], CraftJob.prototype, "citizenName", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'varchar', length: 30 }),
    __metadata("design:type", String)
], CraftJob.prototype, "citizenPhone", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'varchar', length: 240 }),
    __metadata("design:type", String)
], CraftJob.prototype, "address", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'varchar', length: 20 }),
    __metadata("design:type", String)
], CraftJob.prototype, "status", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'int', default: 0 }),
    __metadata("design:type", Number)
], CraftJob.prototype, "timerSecondsLeft", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'int', default: 0 }),
    __metadata("design:type", Number)
], CraftJob.prototype, "hoursRequested", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'int', default: 0 }),
    __metadata("design:type", Number)
], CraftJob.prototype, "hoursAdded", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'int', default: 0 }),
    __metadata("design:type", Number)
], CraftJob.prototype, "pricePerHour", void 0);
__decorate([
    (0, typeorm_1.CreateDateColumn)(),
    __metadata("design:type", Date)
], CraftJob.prototype, "createdAt", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => craft_profile_entity_1.CraftProfile, (p) => p.jobs, { nullable: true, onDelete: 'SET NULL' }),
    __metadata("design:type", Object)
], CraftJob.prototype, "assignee", void 0);
exports.CraftJob = CraftJob = __decorate([
    (0, typeorm_1.Entity)({ name: 'craft_jobs' })
], CraftJob);
//# sourceMappingURL=craft-job.entity.js.map