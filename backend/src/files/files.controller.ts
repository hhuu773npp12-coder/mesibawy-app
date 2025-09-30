import { Controller, Get, Param, Post, UploadedFile, UseInterceptors, Res } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { FilesService } from './files.service';
import type { Response } from 'express';

@Controller('files')
export class FilesController {
  constructor(private readonly files: FilesService) {}

  @Post('upload')
  @UseInterceptors(FileInterceptor('file'))
  upload(@UploadedFile() file: Express.Multer.File) {
    const url = this.files.getPublicUrl(file.filename);
    return { filename: file.filename, url };
  }

  @Get(':filename')
  download(@Param('filename') filename: string, @Res() res: Response) {
    const streamPath = this.files.getPath(filename);
    return res.sendFile(streamPath);
  }
}
