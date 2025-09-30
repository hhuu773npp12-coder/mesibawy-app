"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppModule = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const typeorm_1 = require("@nestjs/typeorm");
const app_controller_1 = require("./app.controller");
const app_service_1 = require("./app.service");
const users_module_1 = require("./users/users.module");
const approvals_module_1 = require("./approvals/approvals.module");
const wallets_module_1 = require("./wallets/wallets.module");
const cards_module_1 = require("./cards/cards.module");
const notifications_module_1 = require("./notifications/notifications.module");
const auth_module_1 = require("./auth/auth.module");
const admin_module_1 = require("./admin/admin.module");
const campaigns_module_1 = require("./campaigns/campaigns.module");
const student_lines_module_1 = require("./student-lines/student-lines.module");
const pricing_module_1 = require("./pricing/pricing.module");
const orders_module_1 = require("./orders/orders.module");
const files_module_1 = require("./files/files.module");
const restaurants_module_1 = require("./restaurants/restaurants.module");
const owner_module_1 = require("./owner/owner.module");
const crafts_module_1 = require("./crafts/crafts.module");
const driver_jobs_module_1 = require("./driver-jobs/driver_jobs.module");
const matching_module_1 = require("./matching/matching.module");
const dev_seed_module_1 = require("./dev-seed/dev-seed.module");
let AppModule = class AppModule {
};
exports.AppModule = AppModule;
exports.AppModule = AppModule = __decorate([
    (0, common_1.Module)({
        imports: [
            config_1.ConfigModule.forRoot({ isGlobal: true }),
            typeorm_1.TypeOrmModule.forRootAsync({
                inject: [config_1.ConfigService],
                useFactory: (config) => ({
                    type: 'postgres',
                    host: config.get('DB_HOST', '127.0.0.1'),
                    port: parseInt(config.get('DB_PORT', '5432'), 10),
                    username: config.get('DB_USER', 'postgres'),
                    password: config.get('DB_PASS', ''),
                    database: config.get('DB_NAME', 'mesibawy'),
                    autoLoadEntities: true,
                    synchronize: config.get('NODE_ENV') === 'development',
                    logging: false,
                }),
            }),
            users_module_1.UsersModule,
            approvals_module_1.ApprovalsModule,
            wallets_module_1.WalletsModule,
            cards_module_1.CardsModule,
            notifications_module_1.NotificationsModule,
            auth_module_1.AuthModule,
            admin_module_1.AdminModule,
            campaigns_module_1.CampaignsModule,
            student_lines_module_1.StudentLinesModule,
            pricing_module_1.PricingModule,
            orders_module_1.OrdersModule,
            files_module_1.FilesModule,
            restaurants_module_1.RestaurantsModule,
            owner_module_1.OwnerModule,
            crafts_module_1.CraftsModule,
            driver_jobs_module_1.DriverJobsModule,
            matching_module_1.MatchingModule,
            dev_seed_module_1.DevSeedModule,
        ],
        controllers: [app_controller_1.AppController],
        providers: [app_service_1.AppService],
    })
], AppModule);
//# sourceMappingURL=app.module.js.map