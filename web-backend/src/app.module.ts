import { Module } from '@nestjs/common';
import { PurchaseModule } from './purchase/purchase.module';
import { QueueModule } from './queue/queue.module';

@Module({
  imports: [
    QueueModule.forRoot('amqp://guest:guest@localhost:5672'),
    PurchaseModule,
  ],
})
export class AppModule {}
