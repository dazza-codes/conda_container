"""
Test the module
"""
from types import ModuleType
import src


def test_src():
    assert isinstance(src, ModuleType)
