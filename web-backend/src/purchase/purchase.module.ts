import { Module } from '@nestjs/common';
import { QueueModule } from 'src/queue/queue.module';
import { PurchaseController } from './purchase.controller';
import { PurchaseService } from './purchase.service';

@Module({
  imports: [QueueModule],
  controllers: [PurchaseController],
  providers: [
    PurchaseService,
  ]
})
export class PurchaseModule {}
