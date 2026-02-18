#!/usr/bin/env python3
"""
MCP Serena Integration for Premortem Analysis

Integrates with MCP Serena for semantic code analysis to enhance
gap detection with codebase-level insights.
"""

import json
import subprocess
from dataclasses import dataclass
from typing import List, Dict, Optional


@dataclass
class SerenaSymbol:
    """Symbol found by Serena"""

    name: str
    kind: str  # "function", "class", "interface", etc.
    file_path: str
    line: int
    documentation: Optional[str] = None


@dataclass
class SerenaSearchResult:
    """Result from Serena search"""

    query: str
    symbols: List[SerenaSymbol]
    success: bool
    error: Optional[str] = None


class SerenaClient:
    """
    Client for MCP Serena integration

    Note: This is a stub implementation that would need to be
    integrated with actual MCP Serena tooling when available.
    For now, it falls back to grep-based search.
    """

    def __init__(self):
        self.available = self._check_availability()

    def _check_availability(self) -> bool:
        """Check if semantic analysis tool is available"""
        # NOTE: Semantic code analysis integration postponed (2026-02-18)
        # Rationale: ripgrep-based search provides sufficient functionality
        # for premortem analysis. May reconsider if deep semantic analysis
        # becomes critical in the future.
        return False

    def find_symbol(self, symbol_name: str) -> SerenaSearchResult:
        """
        Find symbol in codebase

        Args:
            symbol_name: Name of symbol to find

        Returns:
            SerenaSearchResult with found symbols
        """
        if not self.available:
            return self._fallback_search(symbol_name)

        # NOTE: Semantic analysis API integration postponed - using grep-based fallback
        # Future: Consider integrating semantic code analysis tools when available
        return SerenaSearchResult(
            query=symbol_name,
            symbols=[],
            success=False,
            error="Semantic analysis not available",
        )

    def _fallback_search(self, pattern: str) -> SerenaSearchResult:
        """
        Fallback to grep-based search when Serena is unavailable

        Args:
            pattern: Search pattern

        Returns:
            SerenaSearchResult with found matches
        """
        try:
            # Use ripgrep for fast searching
            result = subprocess.run(
                [
                    "rg",
                    "--json",
                    "--max-count",
                    "10",
                    "--type-add",
                    "code:*.{ts,tsx,js,jsx,py,go,rs,java}",
                    "--type",
                    "code",
                    pattern,
                ],
                capture_output=True,
                text=True,
                timeout=5,
            )

            symbols = []
            if result.returncode == 0:
                for line in result.stdout.strip().split("\n"):
                    if not line:
                        continue
                    try:
                        match = json.loads(line)
                        if match.get("type") == "match":
                            data = match.get("data", {})
                            symbols.append(
                                SerenaSymbol(
                                    name=pattern,
                                    kind="unknown",
                                    file_path=data.get("path", {}).get("text", ""),
                                    line=data.get("line_number", 0),
                                    documentation=None,
                                )
                            )
                    except json.JSONDecodeError:
                        continue

            return SerenaSearchResult(
                query=pattern, symbols=symbols, success=True, error=None
            )

        except subprocess.TimeoutExpired:
            return SerenaSearchResult(
                query=pattern, symbols=[], success=False, error="Search timeout"
            )
        except FileNotFoundError:
            # ripgrep not available, return empty result
            return SerenaSearchResult(
                query=pattern, symbols=[], success=False, error="ripgrep not available"
            )
        except Exception as e:
            return SerenaSearchResult(
                query=pattern, symbols=[], success=False, error=str(e)
            )

    def search_for_pattern(self, pattern: str) -> SerenaSearchResult:
        """
        Search for code pattern in codebase

        Args:
            pattern: Pattern to search for

        Returns:
            SerenaSearchResult with matches
        """
        # For now, delegate to find_symbol
        return self.find_symbol(pattern)

    def find_referencing_symbols(self, symbol_name: str) -> SerenaSearchResult:
        """
        Find symbols that reference the given symbol

        Args:
            symbol_name: Symbol to find references for

        Returns:
            SerenaSearchResult with referencing symbols
        """
        # For now, use same search as find_symbol
        return self.find_symbol(symbol_name)


class SerenaEnhancedAnalyzer:
    """
    Enhanced gap analyzer with Serena integration

    This class extends gap analysis by searching the codebase
    for implementations related to the questions.
    """

    def __init__(self):
        self.serena = SerenaClient()

    def extract_search_terms(self, question: Dict) -> List[str]:
        """
        Extract relevant search terms from question

        Args:
            question: Question dict

        Returns:
            List of search terms
        """
        terms = []

        # Add triggers
        terms.extend(question.get("triggers", []))

        # Extract key phrases from question text
        text = question.get("text", "")
        # Simple extraction: capitalize words (likely to be class/function names)
        words = text.split()
        for word in words:
            if word[0].isupper() and len(word) > 3:
                terms.append(word)

        # Category-specific terms
        category = question.get("category", "")
        if category == "Authentication":
            terms.extend(["auth", "login", "token", "session"])
        elif category == "Security":
            terms.extend(["encrypt", "hash", "secure", "validate"])
        elif category == "Performance":
            terms.extend(["cache", "optimize", "index", "query"])

        return list(set(terms))[:5]  # Top 5 unique terms

    def search_codebase(self, question: Dict) -> Dict[str, List[SerenaSymbol]]:
        """
        Search codebase for implementations related to question

        Args:
            question: Question dict

        Returns:
            Dict mapping search term to found symbols
        """
        search_terms = self.extract_search_terms(question)
        results = {}

        for term in search_terms:
            search_result = self.serena.find_symbol(term)
            if search_result.success and search_result.symbols:
                results[term] = search_result.symbols

        return results

    def enhance_auto_answer(
        self, auto_answer: str, codebase_results: Dict[str, List[SerenaSymbol]]
    ) -> str:
        """
        Enhance auto answer with codebase findings

        Args:
            auto_answer: Original auto answer
            codebase_results: Search results from codebase

        Returns:
            Enhanced answer text
        """
        if not codebase_results:
            return auto_answer

        enhancements = ["\n\n## Codebase Analysis\n"]

        for term, symbols in codebase_results.items():
            enhancements.append(f"\n### Found: `{term}`\n")
            for symbol in symbols[:3]:  # Top 3 matches
                enhancements.append(
                    f"- {symbol.kind} in `{symbol.file_path}:{symbol.line}`"
                )

        return auto_answer + "\n".join(enhancements)


# Example usage
if __name__ == "__main__":
    # Test Serena integration
    client = SerenaClient()

    # Test search
    result = client.find_symbol("authenticate")
    print(f"Search for 'authenticate': {len(result.symbols)} results")

    if result.symbols:
        for symbol in result.symbols[:3]:
            print(f"  - {symbol.file_path}:{symbol.line}")
