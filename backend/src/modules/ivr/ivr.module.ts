import { Module } from "@nestjs/common"
import { TypeOrmModule } from "@nestjs/typeorm"
import { IvrService } from "./ivr.service"
import { IvrController } from "./ivr.controller"
import { Ivr } from "./entities/ivr.entity"
import { IvrOption } from "./entities/ivr-option.entity"

@Module({
  imports: [TypeOrmModule.forFeature([Ivr, IvrOption])],
  controllers: [IvrController],
  providers: [IvrService],
})
export class IvrModule {}
