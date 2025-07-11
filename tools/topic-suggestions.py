#!/usr/bin/env python3
"""
Topic Suggestion Tool for DevDogs Knowledge Base

This tool analyzes existing content and suggests new article/blog topics
based on content gaps, trends, and the author's expertise areas.
"""

import os
import json
import re
from datetime import datetime
from collections import defaultdict, Counter
import random

class TopicSuggestionEngine:
    def __init__(self, repo_path="."):
        self.repo_path = repo_path
        self.content_categories = defaultdict(list)
        self.blog_categories = defaultdict(list)
        self.keywords = Counter()
        
    def analyze_content(self):
        """Analyze existing content to understand patterns and topics"""
        # Analyze System Administrator content
        sysadmin_path = os.path.join(self.repo_path, "System Administrator")
        if os.path.exists(sysadmin_path):
            self._analyze_directory(sysadmin_path, "System Administrator")
        
        # Analyze Developers content
        dev_path = os.path.join(self.repo_path, "Developers")
        if os.path.exists(dev_path):
            self._analyze_directory(dev_path, "Developers")
        
        # Analyze Blog content
        blog_path = os.path.join(self.repo_path, "Blogs/DevDogs")
        if os.path.exists(blog_path):
            self._analyze_blog_directory(blog_path)
    
    def _analyze_directory(self, path, category):
        """Recursively analyze directory for content"""
        for root, dirs, files in os.walk(path):
            for file in files:
                if file.endswith('.md'):
                    file_path = os.path.join(root, file)
                    rel_path = os.path.relpath(file_path, path)
                    self.content_categories[category].append({
                        'title': file.replace('.md', '').replace('-', ' ').replace('_', ' '),
                        'path': rel_path,
                        'category': self._get_subcategory(rel_path)
                    })
                    
                    # Extract keywords from filename and path
                    keywords = self._extract_keywords(file_path)
                    self.keywords.update(keywords)
    
    def _analyze_blog_directory(self, path):
        """Analyze blog directory structure"""
        for root, dirs, files in os.walk(path):
            for file in files:
                if file.endswith('.md') and file != 'Index.md':
                    file_path = os.path.join(root, file)
                    rel_path = os.path.relpath(file_path, path)
                    
                    # Extract category from path
                    path_parts = rel_path.split(os.sep)
                    if len(path_parts) >= 2:
                        category = path_parts[0]
                        year = path_parts[1] if len(path_parts) > 2 else "Unknown"
                        
                        self.blog_categories[category].append({
                            'title': file.replace('.md', '').replace('-', ' ').replace('_', ' '),
                            'path': rel_path,
                            'year': year
                        })
    
    def _get_subcategory(self, path):
        """Extract subcategory from path"""
        parts = path.split(os.sep)
        return parts[0] if len(parts) > 1 else "General"
    
    def _extract_keywords(self, file_path):
        """Extract keywords from file path and optionally content"""
        keywords = []
        
        # Extract from filename
        filename = os.path.basename(file_path).replace('.md', '')
        words = re.findall(r'\b[A-Za-z]{3,}\b', filename.replace('-', ' ').replace('_', ' '))
        keywords.extend([word.lower() for word in words])
        
        # Extract from path
        path_words = re.findall(r'\b[A-Za-z]{3,}\b', file_path.replace('/', ' ').replace('-', ' ').replace('_', ' '))
        keywords.extend([word.lower() for word in path_words])
        
        return keywords
    
    def generate_suggestions(self):
        """Generate topic suggestions based on analysis"""
        suggestions = {
            "system_administration": self._generate_sysadmin_suggestions(),
            "development": self._generate_dev_suggestions(),
            "blog_topics": self._generate_blog_suggestions(),
            "trending_topics": self._generate_trending_suggestions()
        }
        
        return suggestions
    
    def _generate_sysadmin_suggestions(self):
        """Generate system administration topic suggestions"""
        existing_topics = [item['title'].lower() for items in self.content_categories.values() for item in items]
        
        suggestions = []
        
        # Infrastructure and DevOps suggestions
        infra_topics = [
            "Setting up GitLab CI/CD Pipeline",
            "Docker Swarm vs Kubernetes Comparison",
            "Terraform Infrastructure as Code Guide",
            "Ansible Playbook for Server Configuration",
            "Monitoring with Grafana and Prometheus",
            "Setting up ELK Stack for Log Management",
            "Backup Strategies for Proxmox VE",
            "High Availability Setup with HAProxy",
            "Container Security Best Practices",
            "Network Security with pfSense"
        ]
        
        for topic in infra_topics:
            if not any(key in topic.lower() for key in existing_topics):
                suggestions.append({
                    'title': topic,
                    'category': 'Infrastructure',
                    'difficulty': 'Intermediate',
                    'rationale': 'Extends existing infrastructure knowledge'
                })
        
        # Cloud and virtualization suggestions
        cloud_topics = [
            "Migrating from VMware to Proxmox",
            "Setting up OpenStack Private Cloud",
            "Kubernetes Cluster on Raspberry Pi",
            "AWS EKS vs Self-hosted Kubernetes",
            "Setting up Ceph Storage Cluster",
            "LXC vs Docker Container Comparison"
        ]
        
        for topic in cloud_topics:
            if not any(key in topic.lower() for key in existing_topics):
                suggestions.append({
                    'title': topic,
                    'category': 'Cloud & Virtualization',
                    'difficulty': 'Advanced',
                    'rationale': 'Builds on existing virtualization expertise'
                })
        
        return suggestions[:8]  # Return top 8 suggestions
    
    def _generate_dev_suggestions(self):
        """Generate development topic suggestions"""
        suggestions = []
        
        # .NET/C# suggestions
        dotnet_topics = [
            "Building Microservices with .NET 8",
            "ASP.NET Core Performance Optimization",
            "Implementing JWT Authentication in ASP.NET Core",
            "Building RESTful APIs with Minimal APIs",
            "Entity Framework Core Advanced Patterns",
            "Blazor Server vs Blazor WebAssembly",
            "Testing Strategies for .NET Applications",
            "Implementing CQRS Pattern in .NET"
        ]
        
        for topic in dotnet_topics:
            suggestions.append({
                'title': topic,
                'category': 'Development',
                'technology': '.NET/C#',
                'difficulty': 'Intermediate',
                'rationale': 'Builds on existing .NET expertise'
            })
        
        # DevOps and tooling
        devops_topics = [
            "Setting up SonarQube for Code Quality",
            "Automated Testing with GitHub Actions",
            "Building Docker Images for .NET Apps",
            "Setting up Development Environment with VS Code",
            "API Documentation with Swagger/OpenAPI"
        ]
        
        for topic in devops_topics:
            suggestions.append({
                'title': topic,
                'category': 'Development',
                'technology': 'DevOps',
                'difficulty': 'Intermediate',
                'rationale': 'Combines development and operations knowledge'
            })
        
        return suggestions[:6]  # Return top 6 suggestions
    
    def _generate_blog_suggestions(self):
        """Generate blog topic suggestions"""
        suggestions = []
        
        # HomeLabs topics
        homelab_topics = [
            "Building a Budget HomeLab in 2024",
            "Power Consumption Optimization for HomeLabs",
            "Disaster Recovery Planning for Home Infrastructure",
            "Setting up Network Monitoring Dashboard",
            "HomeLab Security Best Practices",
            "Upgrading HomeLab Hardware: Lessons Learned"
        ]
        
        for topic in homelab_topics:
            suggestions.append({
                'title': topic,
                'category': 'HomeLabs',
                'type': 'Tutorial/Experience',
                'rationale': 'Shares practical HomeLab experience'
            })
        
        # Technical journey topics
        journey_topics = [
            "My Journey from Windows Admin to Linux Expert",
            "Learning Kubernetes: Challenges and Victories",
            "Building Production-Ready .NET Applications",
            "From Bare Metal to Cloud: Infrastructure Evolution"
        ]
        
        for topic in journey_topics:
            suggestions.append({
                'title': topic,
                'category': 'Life/Career',
                'type': 'Personal Story',
                'rationale': 'Shares learning journey and experiences'
            })
        
        return suggestions[:6]  # Return top 6 suggestions
    
    def _generate_trending_suggestions(self):
        """Generate suggestions based on current tech trends"""
        trending_topics = [
            {
                'title': 'Implementing AI/ML Workloads on Kubernetes',
                'category': 'Emerging Tech',
                'trend': 'AI/ML Integration',
                'difficulty': 'Advanced'
            },
            {
                'title': 'Edge Computing with K3s and IoT Devices',
                'category': 'Edge Computing',
                'trend': 'Edge/IoT',
                'difficulty': 'Intermediate'
            },
            {
                'title': 'Sustainable IT: Green Computing in HomeLabs',
                'category': 'Sustainability',
                'trend': 'Green Tech',
                'difficulty': 'Beginner'
            },
            {
                'title': 'Zero Trust Security Architecture Implementation',
                'category': 'Security',
                'trend': 'Zero Trust',
                'difficulty': 'Advanced'
            },
            {
                'title': 'Platform Engineering: Building Developer Platforms',
                'category': 'Platform Engineering',
                'trend': 'Platform Engineering',
                'difficulty': 'Advanced'
            }
        ]
        
        return trending_topics
    
    def print_suggestions(self, suggestions):
        """Print formatted suggestions"""
        print("🚀 DevDogs Knowledge Base - Topic Suggestions")
        print("=" * 50)
        print(f"Generated on: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print()
        
        for category, items in suggestions.items():
            if not items:
                continue
                
            print(f"## {category.replace('_', ' ').title()}")
            print("-" * 30)
            
            for i, item in enumerate(items, 1):
                print(f"{i}. **{item['title']}**")
                
                if 'category' in item:
                    print(f"   📁 Category: {item['category']}")
                if 'difficulty' in item:
                    print(f"   📊 Difficulty: {item['difficulty']}")
                if 'technology' in item:
                    print(f"   💻 Technology: {item['technology']}")
                if 'trend' in item:
                    print(f"   📈 Trend: {item['trend']}")
                if 'rationale' in item:
                    print(f"   💡 Rationale: {item['rationale']}")
                print()
        
        print("## 💡 How to Use These Suggestions")
        print("-" * 30)
        print("1. Pick topics that align with your current interests and expertise")
        print("2. Consider your audience - what would be most valuable to them?")
        print("3. Start with topics marked as 'Beginner' or 'Intermediate'")
        print("4. Combine multiple small topics into comprehensive guides")
        print("5. Document your learning journey as you explore new topics")
        print()
        print("## 📝 Content Structure Suggestions")
        print("-" * 30)
        print("- **Tutorials**: Step-by-step guides with code examples")
        print("- **Comparisons**: Technology A vs Technology B articles")
        print("- **Best Practices**: Lessons learned and recommendations")
        print("- **Personal Stories**: Your journey and experiences")
        print("- **Quick Tips**: Short, actionable advice")

def main():
    """Main function to run the topic suggestion engine"""
    engine = TopicSuggestionEngine()
    
    print("🔍 Analyzing existing content...")
    engine.analyze_content()
    
    print("💡 Generating suggestions...")
    suggestions = engine.generate_suggestions()
    
    print("\n")
    engine.print_suggestions(suggestions)
    
    # Save suggestions to file
    output_file = f"topic-suggestions-{datetime.now().strftime('%Y%m%d')}.json"
    with open(output_file, 'w') as f:
        json.dump(suggestions, f, indent=2)
    
    print(f"\n💾 Suggestions saved to: {output_file}")

if __name__ == "__main__":
    main()