package com.merproyecto.service.impl;

import com.merproyecto.model.Organizacion;
import com.merproyecto.repository.OrganizacionRepository;
import com.merproyecto.service.OrganizacionService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class OrganizacionServiceImpl implements OrganizacionService {

    private final OrganizacionRepository repository;

    @Override
    public List<Organizacion> findAll() {
        return repository.findAll();
    }

    @Override
    public Optional<Organizacion> findById(Integer id) {
        return repository.findById(id);
    }

    @Override
    public Organizacion save(Organizacion entity) {
        return repository.save(entity);
    }

    @Override
    public void deleteById(Integer id) {
        repository.deleteById(id);
    }
}
