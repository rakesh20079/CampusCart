package com.campuscart.config;

import com.campuscart.entity.Category;
import com.campuscart.repository.CategoryRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class DataInitializer implements CommandLineRunner {

    private static final Logger log = LoggerFactory.getLogger(DataInitializer.class);
    private final CategoryRepository categoryRepository;

    public DataInitializer(CategoryRepository categoryRepository) {
        this.categoryRepository = categoryRepository;
    }

    @Override
    public void run(String... args) {
        if (categoryRepository.count() == 0) {
            log.info("Database has no categories. Seeding default marketplace categories...");
            List<Category> defaultCategories = List.of(
                new Category("Textbooks", "textbooks", "menu_book", 1),
                new Category("Electronics", "electronics", "laptop_mac", 2),
                new Category("Dorm & Living", "dorm", "chair", 3),
                new Category("Lab Gear", "lab-gear", "science", 4),
                new Category("Mobility & Bikes", "mobility", "directions_bike", 5),
                new Category("Clothing", "clothing", "checkroom", 6)
            );
            categoryRepository.saveAll(defaultCategories);
            log.info("Successfully seeded {} default categories.", defaultCategories.size());
        }
    }
}
