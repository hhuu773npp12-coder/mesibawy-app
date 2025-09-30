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

  const port = Number(process.env.PORT || 3000);
  await app.listen(port);
}
bootstrap();
