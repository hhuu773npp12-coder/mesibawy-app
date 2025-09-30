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
exports.CraftProfile = void 0;
const typeorm_1 = require("typeorm");
const craft_job_entity_1 = require("./craft-job.entity");
let CraftProfile = class CraftProfile {
    id;
    userId;
    craftType;
    photos;
    jobs;
};
exports.CraftProfile = CraftProfile;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)('uuid'),
    __metadata("design:type", String)
], CraftProfile.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'uuid' }),
    __metadata("design:type", String)
], CraftProfile.prototype, "userId", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'varchar', length: 30 }),
    __metadata("design:type", String)
], CraftProfile.prototype, "craftType", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'jsonb', nullable: true }),
    __metadata("design:type", Object)
], CraftProfile.prototype, "photos", void 0);
__decorate([
    (0, typeorm_1.OneToMany)(() => craft_job_entity_1.CraftJob, (j) => j.assignee),
    __metadata("design:type", Array)
], CraftProfile.prototype, "jobs", void 0);
exports.CraftProfile = CraftProfile = __decorate([
    (0, typeorm_1.Entity)({ name: 'craft_profiles' })
], CraftProfile);
//# sourceMappingURL=craft-profile.entity.js.map