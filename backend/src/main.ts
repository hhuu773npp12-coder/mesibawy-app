import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Global validation
  app.useGlobalPipes(
    new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true, transform: true })
  );

  // CORS
  const corsOrigin = process.env.WS_CORS_ORIGIN || '*';
  app.enableCors({ origin: corsOrigin === '*' ? true : corsOrigin.split(',') });

  // Serve API under /api to match mobile builds and reverse proxy routes
  app.setGlobalPrefix('api');

  const port = Number(process.env.PORT || 3000);
  // Bind to all interfaces to accept external connections (useful behind Nginx/PM2)
  await app.listen(port, '0.0.0.0');
}
bootstrap();
