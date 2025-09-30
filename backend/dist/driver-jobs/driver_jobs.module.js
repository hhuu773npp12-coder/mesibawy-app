"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.DriverJobsModule = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const driver_jobs_controller_1 = require("./driver_jobs.controller");
const driver_jobs_service_1 = require("./driver_jobs.service");
const owner_module_1 = require("../owner/owner.module");
const matching_module_1 = require("../matching/matching.module");
const driver_job_entity_1 = require("./entities/driver-job.entity");
let DriverJobsModule = class DriverJobsModule {
};
exports.DriverJobsModule = DriverJobsModule;
exports.DriverJobsModule = DriverJobsModule = __decorate([
    (0, common_1.Module)({
        imports: [owner_module_1.OwnerModule, matching_module_1.MatchingModule, typeorm_1.TypeOrmModule.forFeature([driver_job_entity_1.DriverJob])],
        controllers: [driver_jobs_controller_1.DriverJobsController],
        providers: [driver_jobs_service_1.DriverJobsService],
    })
], DriverJobsModule);
//# sourceMappingURL=driver_jobs.module.js.map