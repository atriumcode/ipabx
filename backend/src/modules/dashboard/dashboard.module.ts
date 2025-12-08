import { Module } from "@nestjs/common"
import { TypeOrmModule } from "@nestjs/typeorm"
import { DashboardService } from "./dashboard.service"
import { DashboardController } from "./dashboard.controller"
import { Extension } from "../extensions/entities/extension.entity"
import { Trunk } from "../trunks/entities/trunk.entity"
import { Queue } from "../queues/entities/queue.entity"
import { Cdr } from "../cdr/entities/cdr.entity"

@Module({
  imports: [TypeOrmModule.forFeature([Extension, Trunk, Queue, Cdr])],
  controllers: [DashboardController],
  providers: [DashboardService],
})
export class DashboardModule {}
