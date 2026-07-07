package com.merproyecto.service.impl;

import com.merproyecto.model.Departamento;
import com.merproyecto.repository.DepartamentoRepository;
import com.merproyecto.service.DepartamentoService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class DepartamentoServiceImpl implements DepartamentoService {

    private final DepartamentoRepository repository;

    @Override
    public List<Departamento> findAll() {
        return repository.findAll();
    }

    @Override
    public List<Departamento> findByOrganizacion(Integer idOrganizacion) {
        return repository.findByOrganizacion_IdOrganizacion(idOrganizacion);
    }

    @Override
    public Optional<Departamento> findById(Integer id) {
        return repository.findById(id);
    }

    @Override
    public Departamento save(Departamento departamento) {
        return repository.save(departamento);
    }

    @Override
    public void deleteById(Integer id) {
        repository.deleteById(id);
    }
}