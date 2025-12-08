import { Module } from "@nestjs/common"
import { TypeOrmModule } from "@nestjs/typeorm"
import { RoutesService } from "./routes.service"
import { RoutesController } from "./routes.controller"
import { InboundRoute } from "./entities/inbound-route.entity"
import { OutboundRoute } from "./entities/outbound-route.entity"

@Module({
  imports: [TypeOrmModule.forFeature([InboundRoute, OutboundRoute])],
  controllers: [RoutesController],
  providers: [RoutesService],
})
export class RoutesModule {}
