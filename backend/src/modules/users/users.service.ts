import { Injectable, NotFoundException, ConflictException } from "@nestjs/common"
import type { Repository } from "typeorm"
import * as bcrypt from "bcrypt"
import type { SystemUser } from "./entities/system-user.entity"
import type { CreateUserDto } from "./dto/create-user.dto"
import type { UpdateUserDto } from "./dto/update-user.dto"

@Injectable()
export class UsersService {
  constructor(private readonly userRepository: Repository<SystemUser>) {}

  /**
   * Cria um novo usuário
   */
  async create(createUserDto: CreateUserDto, tenantId: number): Promise<SystemUser> {
    // Verifica se email já existe
    const existingUser = await this.userRepository.findOne({
      where: { email: createUserDto.email },
    })

    if (existingUser) {
      throw new ConflictException("Email já cadastrado")
    }

    // Hash da senha
    const senhaHash = await bcrypt.hash(createUserDto.senha, 10)

    const user = this.userRepository.create({
      ...createUserDto,
      senha: senhaHash,
      tenantId,
    })

    return this.userRepository.save(user)
  }

  /**
   * Lista todos os usuários de um tenant
   */
  async findAll(tenantId: number): Promise<SystemUser[]> {
    return this.userRepository.find({
      where: { tenantId },
      relations: ["tenant"],
      order: { nome: "ASC" },
    })
  }

  /**
   * Busca um usuário por ID
   */
  async findOne(id: number, tenantId: number): Promise<SystemUser> {
    const user = await this.userRepository.findOne({
      where: { id, tenantId },
      relations: ["tenant"],
    })

    if (!user) {
      throw new NotFoundException("Usuário não encontrado")
    }

    return user
  }

  /**
   * Atualiza um usuário
   */
  async update(id: number, updateUserDto: UpdateUserDto, tenantId: number): Promise<SystemUser> {
    const user = await this.findOne(id, tenantId)

    // Se está alterando a senha
    if (updateUserDto.senha) {
      updateUserDto.senha = await bcrypt.hash(updateUserDto.senha, 10)
    }

    Object.assign(user, updateUserDto)
    return this.userRepository.save(user)
  }

  /**
   * Remove um usuário
   */
  async remove(id: number, tenantId: number): Promise<void> {
    const user = await this.findOne(id, tenantId)
    await this.userRepository.remove(user)
  }
}
