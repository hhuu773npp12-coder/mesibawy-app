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
exports.StudentLinesService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const student_line_entity_1 = require("./student-line.entity");
let StudentLinesService = class StudentLinesService {
    repo;
    constructor(repo) {
        this.repo = repo;
    }
    weeklyPriceFor(distanceKm) {
        const d = distanceKm;
        if (d >= 1 && d <= 5)
            return 5000;
        if (d > 5 && d <= 8)
            return 10000;
        if (d > 8 && d <= 12)
            return 15000;
        if (d > 12 && d <= 20)
            return 20000;
        if (d > 20 && d <= 40)
            return 25000;
        if (d > 40 && d <= 50)
            return 30000;
        if (d > 50 && d <= 60)
            return 35000;
        if (d >= 70 && d <= 90)
            return 40000;
        if (d >= 90 && d <= 120)
            return 50000;
        return 0;
    }
    requests = [];
    genId() {
        return 'slr_' + Math.random().toString(36).substring(2, 10);
    }
    createPublicRequest(data) {
        const weeklyPrice = this.weeklyPriceFor(data.distanceKm);
        const req = { id: this.genId(), ...data, weeklyPrice, status: 'PENDING', createdAt: new Date() };
        this.requests.unshift(req);
        return req;
    }
    listPublicRequests() {
        return this.requests;
    }
    approvePublicRequest(id) {
        const r = this.requests.find((x) => x.id === id);
        if (!r)
            return { ok: false, error: 'not_found' };
        r.status = 'APPROVED';
        return { ok: true };
    }
    rejectPublicRequest(id) {
        const r = this.requests.find((x) => x.id === id);
        if (!r)
            return { ok: false, error: 'not_found' };
        r.status = 'REJECTED';
        return { ok: true };
    }
    create(data) {
        const weeklyPrice = this.weeklyPriceFor(data.distanceKm);
        const line = this.repo.create({ ...data, weeklyPrice, active: true });
        return this.repo.save(line);
    }
    list() {
        return this.repo.find({ order: { createdAt: 'DESC' } });
    }
};
exports.StudentLinesService = StudentLinesService;
exports.StudentLinesService = StudentLinesService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(student_line_entity_1.StudentLine)),
    __metadata("design:paramtypes", [typeorm_2.Repository])
], StudentLinesService);
//# sourceMappingURL=student-lines.service.js.map