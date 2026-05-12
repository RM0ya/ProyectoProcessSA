package com.merproyecto.repository;

import com.merproyecto.model.DependenciaTarea;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DependenciaTareaRepository extends JpaRepository<DependenciaTarea, Integer> {
}
