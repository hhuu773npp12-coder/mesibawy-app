import { CraftJob } from './craft-job.entity';
export type CraftType = 'electrician' | 'plumber' | 'blacksmith' | 'ac_tech';
export declare class CraftProfile {
    id: string;
    userId: string;
    craftType: CraftType;
    photos?: string[] | null;
    jobs: CraftJob[];
}
