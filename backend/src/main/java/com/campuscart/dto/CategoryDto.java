package com.campuscart.dto;

import com.campuscart.entity.Category;

public class CategoryDto {
    private Long id;
    private String name;
    private String slug;
    private String iconName;
    private int displayOrder;

    public CategoryDto() {}

    public static CategoryDto fromEntity(Category category) {
        if (category == null) return null;
        CategoryDto dto = new CategoryDto();
        dto.setId(category.getId());
        dto.setName(category.getName());
        dto.setSlug(category.getSlug());
        dto.setIconName(category.getIconName());
        dto.setDisplayOrder(category.getDisplayOrder());
        return dto;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getSlug() { return slug; }
    public void setSlug(String slug) { this.slug = slug; }

    public String getIconName() { return iconName; }
    public void setIconName(String iconName) { this.iconName = iconName; }

    public int getDisplayOrder() { return displayOrder; }
    public void setDisplayOrder(int displayOrder) { this.displayOrder = displayOrder; }
}
