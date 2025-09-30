import { FilesService } from './files.service';
import type { Response } from 'express';
export declare class FilesController {
    private readonly files;
    constructor(files: FilesService);
    upload(file: Express.Multer.File): {
        filename: string;
        url: string;
    };
    download(filename: string, res: Response): void;
}
