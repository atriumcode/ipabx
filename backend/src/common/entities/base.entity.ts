import { CreateDateColumn, UpdateDateColumn, PrimaryGeneratedColumn } from "typeorm"

/**
 * Entidade base com campos comuns a todas as tabelas
 */
export abstract class BaseEntity {
  @PrimaryGeneratedColumn()
  id: number

  @CreateDateColumn({ name: "data_criacao" })
  dataCriacao: Date

  @UpdateDateColumn({ name: "data_atualizacao" })
  dataAtualizacao: Date
}
