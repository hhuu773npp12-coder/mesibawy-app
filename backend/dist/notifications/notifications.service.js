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
exports.NotificationsService = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const notification_entity_1 = require("./notification.entity");
const user_entity_1 = require("../users/user.entity");
let NotificationsService = class NotificationsService {
    config;
    repo;
    usersRepo;
    appId;
    apiKey;
    constructor(config, repo, usersRepo) {
        this.config = config;
        this.repo = repo;
        this.usersRepo = usersRepo;
        this.appId = this.config.get('ONESIGNAL_APP_ID', '');
        this.apiKey = this.config.get('ONESIGNAL_API_KEY', '');
    }
    ensureConfigured() {
        if (!this.appId || !this.apiKey) {
            throw new common_1.HttpException('OneSignal is not configured', common_1.HttpStatus.PRECONDITION_REQUIRED);
        }
    }
    async sendToAll(title, message, data) {
        this.ensureConfigured();
        const payload = {
            app_id: this.appId,
            included_segments: ['Total Subscriptions'],
            headings: { en: title, ar: title },
            contents: { en: message, ar: message },
            data,
        };
        const res = await fetch('https://api.onesignal.com/api/v1/notifications', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                Authorization: `Basic ${this.apiKey}`,
            },
            body: JSON.stringify(payload),
        });
        if (!res.ok)
            throw new common_1.HttpException('OneSignal error', res.status);
        return res.json();
    }
    async sendToExternalUserIds(userIds, title, message, data) {
        this.ensureConfigured();
        const payload = {
            app_id: this.appId,
            include_external_user_ids: userIds,
            headings: { en: title, ar: title },
            contents: { en: message, ar: message },
            data,
        };
        const res = await fetch('https://api.onesignal.com/api/v1/notifications', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                Authorization: `Basic ${this.apiKey}`,
            },
            body: JSON.stringify(payload),
        });
        if (!res.ok)
            throw new common_1.HttpException('OneSignal error', res.status);
        return res.json();
    }
    async sendToTags(tags, title, message, data) {
        this.ensureConfigured();
        const payload = {
            app_id: this.appId,
            filters: tags.map((t, i) => i === 0
                ? { field: 'tag', key: t.key, relation: t.relation, value: t.value }
                : [{ operator: 'AND' }, { field: 'tag', key: t.key, relation: t.relation, value: t.value }]).flat(),
            headings: { en: title, ar: title },
            contents: { en: message, ar: message },
            data,
        };
        const res = await fetch('https://api.onesignal.com/api/v1/notifications', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                Authorization: `Basic ${this.apiKey}`,
            },
            body: JSON.stringify(payload),
        });
        if (!res.ok)
            throw new common_1.HttpException('OneSignal error', res.status);
        return res.json();
    }
    async listForUser(userId) {
        const user = await this.usersRepo.findOne({ where: { id: userId } });
        if (!user)
            throw new common_1.NotFoundException('User not found');
        return this.repo.find({ where: { user }, order: { createdAt: 'DESC' } });
    }
    async markAllRead(userId) {
        const user = await this.usersRepo.findOne({ where: { id: userId } });
        if (!user)
            throw new common_1.NotFoundException('User not found');
        await this.repo.createQueryBuilder()
            .update(notification_entity_1.NotificationEntity)
            .set({ read: true })
            .where('userId = :uid', { uid: userId })
            .andWhere('read = false')
            .execute();
        const unread = await this.repo.count({ where: { user, read: false } });
        return { ok: true, unread };
    }
};
exports.NotificationsService = NotificationsService;
exports.NotificationsService = NotificationsService = __decorate([
    (0, common_1.Injectable)(),
    __param(1, (0, typeorm_1.InjectRepository)(notification_entity_1.NotificationEntity)),
    __param(2, (0, typeorm_1.InjectRepository)(user_entity_1.User)),
    __metadata("design:paramtypes", [config_1.ConfigService,
        typeorm_2.Repository,
        typeorm_2.Repository])
], NotificationsService);
//# sourceMappingURL=notifications.service.js.map