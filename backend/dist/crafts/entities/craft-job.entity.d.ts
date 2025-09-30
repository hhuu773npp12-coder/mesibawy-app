import { CraftProfile } from './craft-profile.entity';
export type CraftJobStatus = 'PENDING' | 'ACCEPTED' | 'IN_PROGRESS' | 'PAUSED' | 'COMPLETED' | 'REJECTED';
export declare class CraftJob {
    id: string;
    citizenName: string;
    citizenPhone: string;
    address: string;
    status: CraftJobStatus;
    timerSecondsLeft: number;
    hoursRequested: number;
    hoursAdded: number;
    pricePerHour: number;
    createdAt: Date;
    assignee?: CraftProfile | null;
}
