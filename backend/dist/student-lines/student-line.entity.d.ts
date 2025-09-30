export declare class StudentLine {
    id: string;
    name: string;
    originArea: string;
    destinationArea: string;
    distanceKm: number;
    kind: 'school' | 'university';
    weeklyPrice: number;
    active: boolean;
    createdAt: Date;
    updatedAt: Date;
}
