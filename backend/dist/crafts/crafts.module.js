"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.CraftsModule = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const crafts_controller_1 = require("./crafts.controller");
const crafts_service_1 = require("./crafts.service");
const matching_module_1 = require("../matching/matching.module");
const craft_profile_entity_1 = require("./entities/craft-profile.entity");
const craft_job_entity_1 = require("./entities/craft-job.entity");
let CraftsModule = class CraftsModule {
};
exports.CraftsModule = CraftsModule;
exports.CraftsModule = CraftsModule = __decorate([
    (0, common_1.Module)({
        imports: [matching_module_1.MatchingModule, typeorm_1.TypeOrmModule.forFeature([craft_profile_entity_1.CraftProfile, craft_job_entity_1.CraftJob])],
        providers: [crafts_service_1.CraftsService],
        controllers: [crafts_controller_1.CraftsController],
        exports: [crafts_service_1.CraftsService],
    })
], CraftsModule);
//# sourceMappingURL=crafts.module.js.map