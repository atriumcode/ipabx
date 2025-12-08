import { Module } from "@nestjs/common"
import { TypeOrmModule } from "@nestjs/typeorm"
import { TrunksService } from "./trunks.service"
import { TrunksController } from "./trunks.controller"
import { Trunk } from "./entities/trunk.entity"

@Module({
  imports: [TypeOrmModule.forFeature([Trunk])],
  controllers: [TrunksController],
  providers: [TrunksService],
  exports: [TrunksService],
})
export class TrunksModule {}
