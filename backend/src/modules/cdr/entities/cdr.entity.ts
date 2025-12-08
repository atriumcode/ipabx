import { Entity, Column } from "typeorm"
import { BaseEntity } from "../../../common/entities/base.entity"

@Entity("cdr")
export class Cdr extends BaseEntity {
  @Column({ name: "tenant_id" })
  tenantId: number

  @Column({ name: "uniqueid" })
  uniqueId: string

  @Column({ name: "data_hora", type: "timestamp" })
  dataHora: Date

  @Column({ name: "numero_origem" })
  numeroOrigem: string

  @Column({ name: "numero_destino" })
  numeroDestino: string

  @Column({ name: "ramal_origem", nullable: true })
  ramalOrigem: string

  @Column({ name: "ramal_destino", nullable: true })
  ramalDestino: string

  @Column()
  disposicao: string

  @Column({ type: "integer" })
  duracao: number

  @Column({ name: "tempo_atendimento", type: "integer" })
  tempoAtendimento: number

  @Column({ name: "arquivo_gravacao", nullable: true })
  arquivoGravacao: string

  @Column({ nullable: true })
  contexto: string

  @Column({ name: "canal_origem", nullable: true })
  canalOrigem: string

  @Column({ name: "canal_destino", nullable: true })
  canalDestino: string
}
