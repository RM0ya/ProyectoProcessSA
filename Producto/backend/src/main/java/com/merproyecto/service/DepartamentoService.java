package com.merproyecto.service;

import com.merproyecto.model.Departamento;

import java.util.List;
import java.util.Optional;

public interface DepartamentoService {

    List<Departamento> findAll();

    List<Departamento> findByOrganizacion(Integer idOrganizacion);

    Optional<Departamento> findById(Integer id);

    Departamento save(Departamento departamento);

    void deleteById(Integer id);
}