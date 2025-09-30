import { Injectable } from '@nestjs/common';
import { join } from 'path';

@Injectable()
export class FilesService {
  private readonly uploadDir = join(process.cwd(), 'storage', 'uploads');

  getPath(filename: string): string {
    return join(this.uploadDir, filename);
  }

  getPublicUrl(filename: string): string {
    // Rely on the API base URL from the client; return a relative API path
    return `/files/${filename}`;
  }
}
